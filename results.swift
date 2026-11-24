import SwiftUI
import UIKit

// MARK: - Results View

struct ResultsView: View {
    let result: AnalysisResult
    let originalURL: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ResultsHeader(onDismiss: onDismiss)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    thumbnailSection
                    sourceSection
                    diagnosisSection

                    if !result.relatedDifferent.isEmpty {
                        differentSection
                    }
                    if !result.relatedSimilar.isEmpty {
                        similarSection
                    }
                }
            }

            ResultsBottomBar(onDismiss: onDismiss)
        }
        .background(Color.appBackground)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 69) }
    }

    // MARK: Sections

    private var thumbnailSection: some View {
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
                    .foregroundStyle(Color.appForeground.opacity(0.3))
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            Divider().overlay(alignment: .center) { Color.appDivider }
        }
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !result.mediaSource.isEmpty {
                Text(result.mediaSource)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appForeground)
            }
            if let url = URL(string: originalURL) {
                Link(result.mediaTitle.isEmpty ? originalURL : result.mediaTitle,
                     destination: url)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appForeground)
                    .underline()
            } else {
                Text(result.mediaTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appForeground)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.appDivider).frame(height: 0.5)
        }
    }

    private var diagnosisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diagnosis:")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(Color.appForeground)

            Text(result.summary)
                .font(.system(size: 14, weight: .semibold))
                .tracking(-0.28)
                .foregroundStyle(Color.appForeground)
                .fixedSize(horizontal: false, vertical: true)

            if let score = result.biasScore {
                BiasIndicator(value: score)
                    .padding(.bottom, 4)
                HStack {
                    Text("No bias")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.appSubtle)
                    Spacer()
                    Text("Heavily biased")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.appSubtle)
                }
            }

            if let detail = result.biasDetail {
                ResultDetailCard(icon: "chart.bar.fill", cardTitle: "Bias Detail", cardBody: detail)
            }
            if let detail = result.aiDetail {
                ResultDetailCard(icon: "cpu.fill", cardTitle: "AI Detection", cardBody: detail)
            }
            if let detail = result.factDetail {
                ResultDetailCard(icon: "checkmark.seal.fill", cardTitle: "Fact Check", cardBody: detail)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var differentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle().fill(Color.appDivider).frame(height: 0.5)
                .padding(.horizontal, 0)

            Text("Different:")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(Color.appForeground)
                .padding(.horizontal, 20)

            ForEach(result.relatedDifferent) { item in
                ResultsLinkRow(item: item)
            }
        }
        .padding(.vertical, 16)
    }

    private var similarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle().fill(Color.appDivider).frame(height: 0.5)

            Text("Similar:")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(Color.appForeground)
                .padding(.horizontal, 20)

            ForEach(result.relatedSimilar) { item in
                ResultsLinkRow(item: item)
            }
        }
        .padding(.vertical, 16)
        .padding(.bottom, 20)
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
                .foregroundStyle(Color.appForeground)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Spacer()
                Button(action: { appState.isDarkMode.toggle() }) {
                    Image(systemName: appState.isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.appForeground)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 8)
        .background(Color.appBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appForeground.opacity(0.15))
                .frame(height: 0.5)
        }
    }
}

// MARK: - Results Bottom Bar

struct ResultsBottomBar: View {
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 32) {
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "house.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.appForeground)
                    .frame(width: 50, height: 50)
            }
            .accessibilityLabel("Go to Home")

            Button(action: onDismiss) {
                ZStack {
                    Circle()
                        .fill(Color.appCard)
                        .frame(width: 50, height: 50)
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appForeground)
                }
            }
            .accessibilityLabel("Close results")
            Spacer()
        }
        .frame(height: 54)
        .background(Color.appBackground)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.appForeground.opacity(0.15))
                .frame(height: 0.5)
        }
    }
}

// MARK: - Bias Indicator

private func biasArrowOffset(width: CGFloat, value: Double) -> CGFloat {
    let raw = width * CGFloat(value)
    if raw < 0 { return 0 }
    if raw > width - 14 { return width - 14 }
    return raw
}

struct BiasIndicator: View {
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
                    .foregroundStyle(Color.appForeground)
                    .offset(
                        x: biasArrowOffset(width: geo.size.width, value: value),
                        y: -14
                    )
            }
        }
        .frame(height: 24)
        .padding(.top, 8)
    }
}



// MARK: - Result Detail Card
// Properties renamed to avoid clash with SwiftUI's `body` and `title` protocol members.

struct ResultDetailCard: View {
    let icon: String
    let cardTitle: String
    let cardBody: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appForeground)
                Text(cardTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appForeground)
            }
            Text(cardBody)
                .font(.system(size: 13))
                .foregroundStyle(Color.appForeground.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appCard)
        .cornerRadius(8)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.appDivider, lineWidth: 1)
        }
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
                        .foregroundStyle(Color.appForeground)
                        .underline()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text(item.title)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.appSubtle)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 