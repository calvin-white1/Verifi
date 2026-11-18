import SwiftUI

// MARK: - Results View

struct ResultsView: View {
    let videoURL: URL?
    let videoName: String
    let channelName: String
    let diagnosisSummary: String

    // Sample related content matching the Figma design
    let differentItems: [RelatedItem] = [
        RelatedItem(label: "Different article 1"),
        RelatedItem(label: "Different article 2")
    ]
    let similarItems: [RelatedItem] = [
        RelatedItem(label: "Similar video 1"),
        RelatedItem(label: "Similar video 2")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Video placeholder / thumbnail area
                    ZStack {
                        Color(hex: "#d9d9d9")
                            .frame(height: 183)

                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 12)

                    Divider().padding(.top, 12)

                    // Channel name + video link
                    VStack(alignment: .leading, spacing: 4) {
                        Text(channelName)
                            .font(.system(size: 13))
                            .foregroundColor(.black)

                        if let url = videoURL {
                            Link(videoName, destination: url)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .underline()
                        } else {
                            Text(videoName)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)

                    Divider()

                    // Diagnosis section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Diagnosis:")
                            .font(.system(size: 20, weight: .semibold))
                            .tracking(-0.4)

                        Text(diagnosisSummary)
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(-0.28)
                            .fixedSize(horizontal: false, vertical: true)

                        // Bias arrow indicator
                        BiasIndicator(value: 0.65)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    Divider()

                    // Different section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Different:")
                            .font(.system(size: 20, weight: .semibold))
                            .tracking(-0.4)
                            .padding(.horizontal, 20)

                        ForEach(differentItems) { item in
                            ResultsPlaceholderRow(label: item.label)
                        }
                    }
                    .padding(.vertical, 16)

                    Divider()

                    // Similar section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Similar:")
                            .font(.system(size: 20, weight: .semibold))
                            .tracking(-0.4)
                            .padding(.horizontal, 20)

                        ForEach(similarItems) { item in
                            ResultsPlaceholderRow(label: item.label)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("App name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HamburgerMenuButton()
                }
            }
        }
    }
}

// MARK: - Bias Arrow Indicator
// Represents the rotated arrow icon shown in the Results Figma frame

struct BiasIndicator: View {
    /// 0.0 = fully left (unbiased), 1.0 = fully right (biased)
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
                    .offset(x: geo.size.width * value - 7, y: -14)
            }
        }
        .frame(height: 24)
        .padding(.top, 8)
    }
}

// MARK: - Results Placeholder Row

struct RelatedItem: Identifiable {
    let id = UUID()
    let label: String
}

struct ResultsPlaceholderRow: View {
    let label: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.black)
            Spacer()
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
