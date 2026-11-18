import SwiftUI

// MARK: - App Entry Point

@main
struct Jour270App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
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

// MARK: - App State (shared across tabs)

class AppState: ObservableObject {
    @Published var isSignedIn = false

    // Criteria inputs
    @Published var videoURLString = ""
    @Published var biasDetection = true
    @Published var aiDetection = false
    @Published var factChecking = false

    // Results — populated after analysis
    @Published var showResults = false
    @Published var analysisResult = "This video is/is not biased. Because blah blah blah blah blah blah."
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // Tab 1: Criteria → Results flow
            NavigationView {
                CriteriaView(
                    videoURL: $appState.videoURLString,
                    biasDetection: $appState.biasDetection,
                    aiDetection: $appState.aiDetection,
                    factChecking: $appState.factChecking,
                    onAnalyze: {
                        appState.showResults = true
                    }
                )
                .background(
                    NavigationLink(
                        destination: ResultsView(
                            videoURL: URL(string: appState.videoURLString),
                            videoName: "Video Name",
                            channelName: "Channel name",
                            diagnosisSummary: appState.analysisResult
                        ),
                        isActive: $appState.showResults
                    ) { EmptyView() }
                )
            }
            .tabItem {
                Label("Analyze", systemImage: "magnifyingglass")
            }
            .tag(0)

            // Tab 2: Home feed
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)

            // Tab 3: History
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
        }
        .tint(.black)
    }
}
