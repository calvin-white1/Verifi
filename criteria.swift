import SwiftUI

// MARK: - Criteria Flow View

struct CriteriaFlowView: View {
    var onDismissResults: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            CriteriaView(
                videoURL: $appState.videoURLString,
                biasDetection: $appState.biasDetection,
                aiDetection: $appState.aiDetection,
                factChecking: $appState.factChecking,
                isAnalyzing: appState.isAnalyzing,
                errorMessage: appState.analysisError,
                onAnalyze: { appState.runAnalysis() }
            )
            .background(Color.appBackground)

            if appState.showResults, let result = appState.analysisResult {
                ResultsView(
                    result: result,
                    originalURL: appState.videoURLString,
                    onDismiss: onDismissResults
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.showResults)
    }
}

// MARK: - Criteria View

struct CriteriaView: View {
    @Binding var videoURL: String
    @Binding var biasDetection: Bool
    @Binding var aiDetection: Bool
    @Binding var factChecking: Bool

    var isAnalyzing: Bool
    var errorMessage: String?
    var onAnalyze: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "App name")
            scrollContent
        }
        .background(Color.appBackground)
        .onReceive(NotificationCenter.default.publisher(for: .sharedURLReceived)) { note in
            if let urlString = note.object as? String {
                videoURL = urlString
            }
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let error = errorMessage {
                    errorBanner(error)
                }
                urlInputSection
                criteriaSection
                Spacer(minLength: 48)
                analyzeButton
            }
        }
    }

    private func errorBanner(_ error: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.white)
            Text(error)
                .font(.system(size: 13))
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.85))
        .cornerRadius(8)
        .padding(.horizontal, 35)
        .padding(.top, 20)
    }

    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Insert Video Link Here:")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(Color.appForeground)

            HStack(spacing: 8) {
                TextField("https://...", text: $videoURL)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appForeground)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
                    .padding(.horizontal, 12)
                    .frame(height: 43)
                    .background(Color.appCard)
                    .cornerRadius(5)

                Button(action: {
                    if let str = UIPasteboard.general.string, !str.isEmpty {
                        videoURL = str
                    }
                }) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appForeground)
                        .frame(width: 43, height: 43)
                        .background(Color.appCard)
                        .cornerRadius(5)
                }
                .accessibilityLabel("Paste URL")
            }

            Text("Paste a YouTube, Twitter/X, Instagram, TikTok, or direct image/video URL.")
                .font(.system(size: 11))
                .foregroundStyle(Color.appSubtle)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 35)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }

    private var criteriaSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Analysis Criteria:")
                .font(.system(size: 20, weight: .medium))
                .tracking(-0.4)
                .foregroundStyle(Color.appForeground)
                .padding(.horizontal, 35)

            Rectangle()
                .fill(Color.appDivider)
                .frame(height: 0.5)
                .padding(.horizontal, 35)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 0) {
                CriteriaToggleRow(
                    label: "Bias Detection",
                    description: "Rates political, ideological, or framing bias.",
                    isOn: $biasDetection
                )
                CriteriaToggleRow(
                    label: "AI Detection",
                    description: "Flags likely AI-generated imagery or narration.",
                    isOn: $aiDetection
                )
                CriteriaToggleRow(
                    label: "Fact Checking",
                    description: "Checks key claims against known sources.",
                    isOn: $factChecking
                )
            }
            .padding(.horizontal, 35)
            .padding(.top, 16)
        }
    }

    private var analyzeButton: some View {
        Button(action: onAnalyze) {
            ZStack {
                Text("Analyze")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appBackground)
                    .opacity(isAnalyzing ? 0 : 1)

                if isAnalyzing {
                    HStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.appBackground))
                        Text("Analyzing...")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.appBackground)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isAnalyzing ? Color.appSubtle : Color.appForeground)
            .cornerRadius(8)
        }
        .padding(.horizontal, 35)
        .padding(.bottom, 32)
        .disabled(
            videoURL.trimmingCharacters(in: .whitespaces).isEmpty
            || isAnalyzing
            || (!biasDetection && !aiDetection && !factChecking)
        )
    }
}

// MARK: - Criteria Toggle Row

struct CriteriaToggleRow: View {
    let label: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: { isOn.toggle() }) {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.appForeground, lineWidth: 2)
                    .frame(width: 21, height: 21)
                    .overlay(alignment: .center) {
                        if isOn {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.appForeground)
                        }
                    }
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 16))
                    .tracking(-0.32)
                    .foregroundStyle(Color.appForeground)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appSubtle)
            }

            Spacer()
        }
        .padding(.vertical, 14)
    }
}
