import Foundation
import UIKit

// MARK: - Analysis Models

struct AnalysisCriteria {
    var biasDetection: Bool
    var aiDetection: Bool
    var factChecking: Bool
}

struct AnalysisResult {
    let summary: String              // Plain-language verdict shown at top of Results
    let biasScore: Double?           // 0.0–1.0, nil if bias not requested
    let biasDetail: String?          // Sentence explaining the bias score
    let aiDetail: String?            // nil if AI detection not requested
    let factDetail: String?          // nil if fact-checking not requested
    let relatedDifferent: [RelatedLink]
    let relatedSimilar: [RelatedLink]
    let mediaTitle: String
    let mediaSource: String
    let mediaThumbnail: UIImage?
}

struct RelatedLink: Identifiable {
    let id = UUID()
    let title: String
    let url: URL?
}

// MARK: - Analysis Service

/// Downloads the media pointed to by `mediaURLString`, captures a frame or
/// thumbnail, then asks the OpenAI Chat/Vision API to analyze it.
///
/// Replace `openAIKey` with your actual key, or inject it via an environment
/// variable / Secrets.xcconfig so it never ends up in source control.
class AnalysisService {

    // ── Configuration ────────────────────────────────────────────────────────
    private let openAIKey: String = {
        // Prefer an env-var or xcconfig value; fall back to a placeholder
        // that will produce a clear runtime error rather than a silent one.
        if let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String,
           !key.isEmpty { return key }
        return "REPLACE_WITH_YOUR_OPENAI_API_KEY"
    }()
    private let model = "gpt-4o"            // supports vision
    private let maxTokens = 1024

    // MARK: Analyze

    /// Entry point called from the UI.  Runs entirely on a background Task.
    func analyze(urlString: String, criteria: AnalysisCriteria) async throws -> AnalysisResult {

        guard let mediaURL = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)),
              mediaURL.scheme == "https" || mediaURL.scheme == "http"
        else {
            throw AnalysisError.invalidURL
        }

        // 1. Download and extract a representative frame / thumbnail
        let (image, title, source) = try await fetchMediaPreview(from: mediaURL)

        // 2. Build the vision prompt
        let prompt = buildPrompt(title: title, url: urlString, criteria: criteria)

        // 3. Call the OpenAI Vision API
        let raw = try await callOpenAI(image: image, prompt: prompt)

        // 4. Parse structured JSON from the model response
        let result = try parseResponse(raw, criteria: criteria,
                                       title: title, source: source,
                                       thumbnail: image, originalURL: mediaURL)
        return result
    }

    // MARK: - Media Download

    private func fetchMediaPreview(from url: URL) async throws -> (UIImage?, String, String) {

        // ── YouTube-style: grab the og:image meta tag ──────────────────────
        if url.host?.contains("youtube") == true || url.host?.contains("youtu.be") == true {
            return try await fetchHTMLPreview(from: url)
        }

        // ── Twitter / X ────────────────────────────────────────────────────
        if url.host?.contains("twitter") == true || url.host?.contains("x.com") == true {
            return try await fetchHTMLPreview(from: url)
        }

        // ── Instagram / TikTok / generic social ───────────────────────────
        if url.host?.contains("instagram") == true || url.host?.contains("tiktok") == true {
            return try await fetchHTMLPreview(from: url)
        }

        // ── Direct image URL (jpg, png, gif, webp) ────────────────────────
        let pathExt = url.pathExtension.lowercased()
        if ["jpg", "jpeg", "png", "gif", "webp"].contains(pathExt) {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            return (image, url.lastPathComponent, url.host ?? "")
        }

        // ── Fallback: parse HTML ──────────────────────────────────────────
        return try await fetchHTMLPreview(from: url)
    }

    /// Fetches the page HTML and extracts og:image, og:title, og:site_name.
    private func fetchHTMLPreview(from url: URL) async throws -> (UIImage?, String, String) {
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) "
                         + "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
                         forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        let html = String(data: data, encoding: .utf8) ?? ""

        let title = ogContent(tag: "og:title", in: html)
                 ?? ogContent(tag: "twitter:title", in: html)
                 ?? url.host ?? "Unknown"
        let siteName = ogContent(tag: "og:site_name", in: html) ?? url.host ?? ""
        let imageURLString = ogContent(tag: "og:image", in: html)
                          ?? ogContent(tag: "twitter:image", in: html)

        var image: UIImage?
        if let imgStr = imageURLString, let imgURL = URL(string: imgStr) {
            if let (imgData, _) = try? await URLSession.shared.data(from: imgURL) {
                image = UIImage(data: imgData)
            }
        }

        return (image, title, siteName)
    }

    private func ogContent(tag: String, in html: String) -> String? {
        // Match <meta property="og:xxx" content="VALUE"> or reversed attribute order
        let pattern = #"<meta[^>]+(?:property|name)=["\']"# + NSRegularExpression.escapedPattern(for: tag)
                    + #"["\'][^>]+content=["\']([^"\']+)["\']"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
           let range = Range(match.range(at: 1), in: html) {
            return String(html[range])
        }
        // Also try reversed: content first, then property
        let pattern2 = #"<meta[^>]+content=["\']([^"\']+)["\'][^>]+(?:property|name)=["\']"#
                     + NSRegularExpression.escapedPattern(for: tag) + #"["\']"#
        if let regex2 = try? NSRegularExpression(pattern: pattern2, options: .caseInsensitive),
           let match2 = regex2.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
           let range2 = Range(match2.range(at: 1), in: html) {
            return String(html[range2])
        }
        return nil
    }

    // MARK: - Prompt Building

    private func buildPrompt(title: String, url: String, criteria: AnalysisCriteria) -> String {
        var parts: [String] = []
        parts.append("You are a media-literacy analyst. Analyze the following media content.")
        parts.append("Source URL: \(url)")
        parts.append("Detected title: \(title)")
        parts.append("")
        parts.append("Return your answer as valid JSON with EXACTLY these keys:")
        parts.append("""
{
  "summary": "<one sentence plain-language verdict>",
  "bias_score": <float 0.0–1.0, where 0=no bias, 1=heavily biased>,
  "bias_detail": "<2–3 sentences explaining bias findings>",
  "ai_detail": "<2–3 sentences on AI-generated content likelihood>",
  "fact_detail": "<2–3 sentences on factual accuracy and notable claims>",
  "related_different": [{"title": "...", "url": "..."}, ...],
  "related_similar":   [{"title": "...", "url": "..."}, ...]
}
""")
        parts.append("Include only the keys requested for the active criteria:")

        var active: [String] = ["summary"]
        if criteria.biasDetection  { active += ["bias_score", "bias_detail"] }
        if criteria.aiDetection    { active.append("ai_detail") }
        if criteria.factChecking   { active.append("fact_detail") }
        active += ["related_different", "related_similar"]

        parts.append("Active keys: " + active.joined(separator: ", "))
        parts.append("Set unused keys to null.")
        parts.append("related_different and related_similar must each contain 2 real, verifiable links if possible, otherwise empty arrays.")
        parts.append("Respond with JSON only — no markdown fences, no commentary.")

        return parts.joined(separator: "\n")
    }

    // MARK: - OpenAI Vision Call

    private func callOpenAI(image: UIImage?, prompt: String) async throws -> String {

        let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build message content
        var contentArray: [[String: Any]] = [
            ["type": "text", "text": prompt]
        ]

        // Attach the thumbnail as base64 if we have one
        if let img = image,
           let jpegData = img.jpegData(compressionQuality: 0.7) {
            let b64 = jpegData.base64EncodedString()
            contentArray.append([
                "type": "image_url",
                "image_url": ["url": "data:image/jpeg;base64,\(b64)", "detail": "low"]
            ])
        }

        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "messages": [
                ["role": "user", "content": contentArray]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AnalysisError.apiError("HTTP \(http.statusCode): \(body)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String
        else {
            throw AnalysisError.badResponse
        }

        return content
    }

    // MARK: - Response Parsing

    private func parseResponse(_ raw: String,
                                criteria: AnalysisCriteria,
                                title: String,
                                source: String,
                                thumbnail: UIImage?,
                                originalURL: URL) throws -> AnalysisResult {

        // Strip any accidental markdown fences
        var cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            cleaned = cleaned
                .components(separatedBy: "\n")
                .dropFirst()
                .dropLast()
                .joined(separator: "\n")
        }

        guard let data = cleaned.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            throw AnalysisError.parseError(raw)
        }

        let summary    = json["summary"]    as? String ?? "Analysis complete."
        let biasScore  = json["bias_score"] as? Double
        let biasDetail = json["bias_detail"] as? String
        let aiDetail   = json["ai_detail"]   as? String
        let factDetail = json["fact_detail"] as? String

        func parseLinks(_ key: String) -> [RelatedLink] {
            guard let arr = json[key] as? [[String: Any]] else { return [] }
            return arr.compactMap { dict -> RelatedLink? in
                guard let t = dict["title"] as? String else { return nil }
                let u = (dict["url"] as? String).flatMap { URL(string: $0) }
                return RelatedLink(title: t, url: u)
            }
        }

        return AnalysisResult(
            summary: summary,
            biasScore: criteria.biasDetection ? biasScore : nil,
            biasDetail: criteria.biasDetection ? biasDetail : nil,
            aiDetail: criteria.aiDetection ? aiDetail : nil,
            factDetail: criteria.factChecking ? factDetail : nil,
            relatedDifferent: parseLinks("related_different"),
            relatedSimilar: parseLinks("related_similar"),
            mediaTitle: title,
            mediaSource: source,
            mediaThumbnail: thumbnail
        )
    }
}

// MARK: - Errors

enum AnalysisError: LocalizedError {
    case invalidURL
    case apiError(String)
    case badResponse
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "The URL you entered is not valid."
        case .apiError(let msg):     return "API error: \(msg)"
        case .badResponse:           return "Received an unreadable response from the server."
        case .parseError(let raw):   return "Could not parse the analysis response.\n\nRaw: \(raw.prefix(300))"
        }
    }
}
