import SwiftUI

// MARK: - Results View

struct ResultsView: View {
    let result: AnalysisResult
    let originalURL: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Thumbnail / media preview
                ZStack {
                    Color(hex: "#d9d9d9")
                        .frame(height: 183)

                    if let img = result.mediaThumbnail {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 183)
                            .clipped()
                    } else {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)

                Divider().padding(.top, 12)

                // Source + link
                VStack(alignment: .leading, spacing: 4) {
                    if !result.mediaSource.isEmpty {
                        Text(result.mediaSource)
                            .font(.system(size: 13))
                            .foregroundColor(.black)
                    }
                    if let url = URL(string: originalURL) {
                        Link(result.mediaTitle.isEmpty ? originalURL : result.mediaTitle,
                             destination: url)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .underline()
                    } else {
                        Text(result.mediaTitle)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 12)

                Divider()

                // Diagnosis section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Diagnosis:")
                        .font(.system(size: 20, weight: .semibold))
                        .tracking(-0.4)

                    Text(result.summary)
                        .font(.system(size: 14, weight: .semibold))
                        .tracking(-0.28)
                        .fixedSize(horizontal: false, vertical: true)

                    // Bias gauge (only shown when bias detection was run)
                    if let score = result.biasScore {
                        BiasIndicator(value: score)
                            .padding(.bottom, 4)

                        HStack {
                            Text("No bias")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Heavily biased")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }

                    if let detail = result.biasDetail {
                        ResultDetailCard(icon: "chart.bar.fill", title: "Bias Detail", body: detail)
                    }

                    if let detail = result.aiDetail {
                        ResultDetailCard(icon: "cpu.fill", title: "AI Detection", body: detail)
                    }

                    if let detail = result.factDetail {
                        ResultDetailCard(icon: "checkmark.seal.fill", title: "Fact Check", body: detail)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Different section
                if !result.relatedDifferent.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Different:")
                            .font(.system(size: 20, weight: .semibold))
                            .tracking(-0.4)
                            .padding(.horizontal, 20)

                        ForEach(result.relatedDifferent) { item in
                            ResultsLinkRow(item: item)
                        }
                    }
                    .padding(.vertical, 16)
                }

                // Similar section
                if !result.relatedSimilar.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Similar:")
                            .font(.system(size: 20, weight: .semibold))
                            .tracking(-0.4)
                            .padding(.horizontal, 20)

                        ForEach(result.relatedSimilar) { item in
                            ResultsLinkRow(item: item)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HamburgerMenuButton()
            }
        }
    }
}

// MARK: - Bias Arrow Indicator

struct BiasIndicator: View {
    /// 0.0 = no bias, 1.0 = heavily biased
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.green, Color.yellow, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 8)

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .offset(x: (geo.size.width * CGFloat(value)).clamped(to: 0...(geo.size.width - 14)), y: -14)
            }
        }
        .frame(height: 24)
        .padding(.top, 8)
    }
}

extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Result Detail Card

struct ResultDetailCard: View {
    let icon: String
    let title: String
    let body: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(.black)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
            Text(body)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#333333"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#f5f5f5"))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#e0e0e0"), lineWidth: 1)
        )
    }
}

// MARK: - Results Link Row

struct ResultsLinkRow: View {
    let item: RelatedLink

    var body: some View {
        HStack {
            if let url = item.url {
                Link(destination: url) {
                    Text(item.title)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .underline()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text(item.title)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(Color(hex: "#e0e0e0"), lineWidth: 0.5),
            alignment: .bottom
        )
    }
}