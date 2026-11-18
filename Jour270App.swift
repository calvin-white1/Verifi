import SwiftUI

// MARK: - App Entry Point

@main
struct Jour270App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                // Receives URLs opened via a registered URL scheme (e.g. jour270://)
                // or from the iOS share sheet when the app is set as an action extension.
                .onOpenURL { url in
                    // Strip the custom scheme wrapper if present (jour270://https://...)
                    var urlString = url.absoluteString
                    if let range = urlString.range(of: "://"),
                       urlString.hasPrefix("jour270") {
                        // e.g. jour270://https://youtube.com/... -> https://youtube.com/...
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
        if appState.isSignedIn {
            MainTabView()
                .environmentObject(appState)
        } else {
            SignInView(isSignedIn: $appState.isSignedIn)
        }
    }
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var isSignedIn = false

    // Criteria inputs
    @Published var videoURLString = ""
    @Published var biasDetection = true
    @Published var aiDetection = false
    @Published var factChecking = false

    // Analysis lifecycle
    @Published var isAnalyzing = false
    @Published var showResults = false
    @Published var analysisResult: AnalysisResult? = nil
    @Published var analysisError: String? = nil

    private let service = AnalysisService()

    // History (persisted in UserDefaults)
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
                        thumbnailImage: result.mediaThumbnail
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
}

// MARK: - History Store

struct HistoryStore {
    private static let key = "history_entries_v2"

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
        TabView(selection: $selectedTab) {

            // Tab 0: Criteria -> Results flow
            NavigationView {
                CriteriaView(
                    videoURL: $appState.videoURLString,
                    biasDetection: $appState.biasDetection,
                    aiDetection: $appState.aiDetection,
                    factChecking: $appState.factChecking,
                    isAnalyzing: appState.isAnalyzing,
                    errorMessage: appState.analysisError,
                    onAnalyze: { appState.runAnalysis() }
                )
                .background(
                    NavigationLink(
                        destination: Group {
                            if let result = appState.analysisResult {
                                ResultsView(
                                    result: result,
                                    originalURL: appState.videoURLString
                                )
                            }
                        },
                        isActive: $appState.showResults
                    ) { EmptyView() }
                )
            }
            .tabItem { Label("Analyze", systemImage: "magnifyingglass") }
            .tag(0)

            // Tab 1: Home feed
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(1)

            // Tab 2: History
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }
                .tag(2)
        }
        .tint(.black)
    }
}