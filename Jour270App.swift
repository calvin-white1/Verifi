import SwiftUI

// MARK: - App Entry Point

@main
struct Jour270App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    var urlString = url.absoluteString
                    if let range = urlString.range(of: "://"),
                       urlString.hasPrefix("jour270") {
                        urlString = String(urlString[range.upperBound...])
                    }
                    NotificationCenter.default.post(
                        name: .sharedURLReceived,
                        object: urlString
                    )
                }
        }
    }
}

extension Notification.Name {
    static let sharedURLReceived = Notification.Name("sharedURLReceived")
}

// MARK: - Root View

struct RootView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        MainTabView()
            .environmentObject(appState)
            .preferredColorScheme(appState.isDarkMode ? .dark : .light)
    }
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var isDarkMode: Bool = true

    @Published var videoURLString = ""
    @Published var biasDetection = true
    @Published var aiDetection = false
    @Published var factChecking = false

    @Published var isAnalyzing = false
    @Published var showResults = false
    @Published var analysisResult: AnalysisResult? = nil
    @Published var analysisError: String? = nil

    private let service = AnalysisService()

    @Published var history: [HistoryEntry] = HistoryStore.load()

    func runAnalysis() {
        guard !videoURLString.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isAnalyzing = true
        analysisError = nil
        showResults = false

        let criteria = AnalysisCriteria(
            biasDetection: biasDetection,
            aiDetection: aiDetection,
            factChecking: factChecking
        )
        let urlString = videoURLString

        Task {
            do {
                let result = try await service.analyze(urlString: urlString, criteria: criteria)
                await MainActor.run {
                    self.analysisResult = result
                    self.isAnalyzing = false
                    self.showResults = true

                    let entry = HistoryEntry(
                        title: result.mediaTitle.isEmpty ? urlString : result.mediaTitle,
                        result: result.summary,
                        channelOrSource: result.mediaSource,
                        thumbnailImage: result.mediaThumbnail,
                        criteria: criteria,
                        url: urlString
                    )
                    self.history.insert(entry, at: 0)
                    HistoryStore.save(self.history)
                }
            } catch {
                await MainActor.run {
                    self.analysisError = error.localizedDescription
                    self.isAnalyzing = false
                }
            }
        }
    }

    func resetToHome() {
        showResults = false
        videoURLString = ""
        analysisError = nil
    }
}

// MARK: - History Store

struct HistoryStore {
    private static let key = "history_entries_v3"

    static func load() -> [HistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data)
        else { return [] }
        return decoded
    }

    static func save(_ entries: [HistoryEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                HomeView(onAnalyzeTap: { selectedTab = 1 })
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)

                CriteriaFlowView(onDismissResults: {
                    appState.resetToHome()
                    selectedTab = 0
                })
                .opacity(selectedTab == 1 ? 1 : 0)
                .allowsHitTesting(selectedTab == 1)

                HistoryView()
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 2)
            }
            .ignoresSafeArea(edges: .bottom)

            AppTabBar(selectedTab: $selectedTab)
        }
        .background(Color.appBackground)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Custom Tab Bar

struct AppTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.appForeground.opacity(0.15))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                TabBarButton(icon: "house.fill",       label: "Home",    isActive: selectedTab == 0) { selectedTab = 0 }
                TabBarButton(icon: "magnifyingglass",  label: "Analyze", isActive: selectedTab == 1) { selectedTab = 1 }
                TabBarButton(icon: "clock.fill",       label: "History", isActive: selectedTab == 2) { selectedTab = 2 }
            }
            .frame(height: 49)
            .padding(.bottom, 20)
        }
        .background(Color.appBackground)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundStyle(isActive ? Color.appForeground : Color.appForeground.opacity(0.4))
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Shared App Header

struct AppHeader: View {
    let title: String
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Text(title)
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

// MARK: - Named Colors

extension Color {
    static var appBackground: Color { Color("AppBackground") }
    static var appForeground: Color { Color("AppForeground") }
    static var appCard: Color      { Color("AppCard") }
    static var appDivider: Color   { Color("AppDivider") }
    static var appSubtle: Color    { Color("AppSubtle") }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
