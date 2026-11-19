import SwiftUI
import UIKit

// MARK: - Results View

struct ResultsView: View {
    let result: AnalysisResult
    let originalURL: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header with dismiss (X) button
            ResultsHeader(onDismiss: onDismiss)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Thumbnail / media preview
                    ZStack {
                        Color.appCard
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
                                .foregroundColor(Color.appForeground.opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 12)

                    Divider().overlay(Color.appDivider).padding(.top, 12)

                    // Source + link
                    VStack(alignment: .leading, spacing: 4) {
                        if !result.mediaSource.isEmpty {
                            Text(result.mediaSource)
                                .font(.system(size: 13))
                                .foregroundColor(Color.appForeground)
                        }
                        if let url = URL(string: originalURL) {
                            Link(result.mediaTitle.isEmpty ? originalURL : result.mediaTitle,
                                 destination: url)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.appForeground)
                                .underline()
                        } else {
                            Text(result.mediaTitle)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.appForeground)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)

                    Divider().overlay(Color.appDivider)

                    // Diagnosis section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Diagnosis:")
                            .font(.system(size: 20, weight: .semibold))
                            .tracking(-0.4)
                            .foregroundColor(Color.appForeground)

                        Text(result.summary)
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(-0.28)
                            .foregroundColor(Color.appForeground)
                            .fixedSize(horizontal: false, vertical: true)

                        // Bias gauge (only shown when bias detection was run)
                        if let score = result.biasScore {
                            BiasIndicator(value: score)
                                .padding(.bottom, 4)

                            HStack {
                                Text("No bias")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color.appSubtle)
                                Spacer()
                                Text("Heavily biased")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color.appSubtle)
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
                        Divider().overlay(Color.appDivider)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Different:")
                                .font(.system(size: 20, weight: .semibold))
                                .tracking(-0.4)
                                .foregroundColor(Color.appForeground)
                                .padding(.horizontal, 20)

                            ForEach(result.relatedDifferent) { item in
                                ResultsLinkRow(item: item)
                            }
                        }
                        .padding(.vertical, 16)
                    }

                    // Similar section
                    if !result.relatedSimilar.isEmpty {
                        Divider().overlay(Color.appDivider)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Similar:")
                                .font(.system(size: 20, weight: .semibold))
                                .tracking(-0.4)
                                .foregroundColor(Color.appForeground)
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

            // Bottom dismiss bar: home icon + X button
            ResultsBottomBar(onDismiss: onDismiss)
        }
        .background(Color.appBackground)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 69) }
    }
}

// MARK: - Results Header

struct ResultsHeader: View {
    var onDismiss: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Text("Results")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundColor(Color.appForeground)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Spacer()
                Button(action: { appState.isDarkMode.toggle() }) {
                    Image(systemName: appState.isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.appForeground)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 8)
        .background(Color.appBackground)
        .overlay(
            Rectangle()
                .fill(Color.appForeground.opacity(0.15))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

// MARK: - Results Bottom Bar

struct ResultsBottomBar: View {
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 32) {
            Spacer()

            // Home button
            Button(action: onDismiss) {
                Image(systemName: "house.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color.appForeground)
                    .frame(width: 50, height: 50)
            }
            .accessibilityLabel("Go to Home")

            // X (close) button
            Button(action: onDismiss) {
                ZStack {
                    Circle()
                        .fill(Color.appCard)
                        .frame(width: 50, height: 50)
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.appForeground)
                }
            }
            .accessibilityLabel("Close results")

            Spacer()
        }
        .frame(height: 54)
        .background(Color.appBackground)
        .overlay(
            Rectangle()
                .fill(Color.appForeground.opacity(0.15))
                .frame(height: 0.5),
            alignment: .top
        )
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
                    .foregroundColor(Color.appForeground)
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
                    .foregroundColor(Color.appForeground)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.appForeground)
            }
            Text(body)
                .font(.system(size: 13))
                .foregroundColor(Color.appForeground.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appCard)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.appDivider, lineWidth: 1)
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
                        .foregroundColor(Color.appForeground)
                        .underline()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text(item.title)
                    .font(.system(size: 14))
                    .foregroundColor(Color.appForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(Color.appSubtle)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.appBackground)
        .overlay(
            Rectangle()
                .fill(Color.appDivider)
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}
