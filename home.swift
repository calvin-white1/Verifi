import SwiftUI

// MARK: - Shared Tab Bar

struct MainTabView: View {
    @Binding var selectedTab: ContentView.Tab

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(ContentView.Tab.home)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(ContentView.Tab.history)
        }
        .tint(.black)
    }
}

// MARK: - Article Card Model

struct ArticleCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let url: URL?
}

// MARK: - Home View

struct HomeView: View {

    // Sample data mirroring the Figma design placeholders
    let videoURL = URL(string: "https://www.youtube.com/watch?v=A98KioIRvtQ")
    let channelName = "Channel name"
    let videoName = "Video Name"
    let diagnosisSummary = "This Video is/is not biased. because blah blah blah blah blah blah."

    let differentCards: [ArticleCard] = [
        ArticleCard(
            title: "The lucky scoops trend: Why it's fun but comes with gambling risks",
            description: "The 'surprise' element behind the prizes you win can be addicting",
            url: URL(string: "https://www.cbc.ca/kidsnews/post/is-the-lucky-scoops-trend-gambling-why-kids-should-be-wary-of-the-trend")
        ),
        ArticleCard(
            title: "The lucky scoops trend: Why it's fun but comes with gambling risks",
            description: "The 'surprise' element behind the prizes you win can be addicting",
            url: URL(string: "https://www.cbc.ca/kidsnews/post/is-the-lucky-scoops-trend-gambling-why-kids-should-be-wary-of-the-trend")
        )
    ]

    let similarCards: [ArticleCard] = [
        ArticleCard(
            title: "Video Name",
            description: "",
            url: URL(string: "https://www.youtube.com/watch?v=A98KioIRvtQ")
        ),
        ArticleCard(
            title: "Video Name",
            description: "",
            url: URL(string: "https://www.youtube.com/watch?v=A98KioIRvtQ")
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Banner image
                    Image("home_banner")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 185)
                        .clipped()
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

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(differentCards) { card in
                                    DifferentArticleCard(card: card)
                                }
                            }
                            .padding(.horizontal, 10)
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

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(similarCards) { card in
                                    SimilarVideoCard(card: card)
                                }
                            }
                            .padding(.horizontal, 10)
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

// MARK: - Different Article Card

struct DifferentArticleCard: View {
    let card: ArticleCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = card.url {
                Link(destination: url) {
                    Text(card.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .underline()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Text(card.description)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(width: 224, height: 145, alignment: .topLeading)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#e0e0e0"), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

// MARK: - Similar Video Card

struct SimilarVideoCard: View {
    let card: ArticleCard

    var body: some View {
        VStack(spacing: 4) {
            Image("home_thumbnail")
                .resizable()
                .scaledToFill()
                .frame(width: 172, height: 96)
                .clipped()

            if let url = card.url {
                Link(card.title, destination: url)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(width: 252, height: 145)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#e0e0e0"), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

// MARK: - Hamburger Menu Button

struct HamburgerMenuButton: View {
    var body: some View {
        VStack(spacing: 4) {
            Rectangle().frame(width: 18, height: 2)
            Rectangle().frame(width: 14, height: 2)
            Rectangle().frame(width: 18, height: 2)
        }
        .foregroundColor(.black)
    }
}

// MARK: - Color Helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
