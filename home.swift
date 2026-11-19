import SwiftUI
import UIKit

// MARK: - Home View
// Shows the most recent analysis result. If nothing has been analyzed yet,
// shows a prompt to run the first analysis.

struct HomeView: View {
    var onAnalyzeTap: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "App name")

            if let result = appState.history.first {
                HomeResultContent(entry: result)
            } else {
                HomeEmptyState(onAnalyzeTap: onAnalyzeTap)
            }
        }
        .background(Color.appBackground)
        // Extra bottom padding so content clears the tab bar
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 69) }
    }
}

// MARK: - Home Result Content

struct HomeResultContent: View {
    let entry: HistoryEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Thumbnail
                ZStack {
                    Color.appCard
                        .frame(height: 185)

                    if let img = entry.thumbnailImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 185)
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

                // Source + title
                VStack(alignment: .leading, spacing: 4) {
                    if !entry.channelOrSource.isEmpty {
                        Text(entry.channelOrSource)
                            .font(.system(size: 13))
                            .foregroundColor(Color.appForeground)
                    }
                    Text(entry.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.appForeground)
                        .underline()
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 12)

                Divider().overlay(Color.appDivider)

                // Diagnosis
                VStack(alignment: .leading, spacing: 8) {
                    Text("Diagnosis:")
                        .font(.system(size: 20, weight: .semibold))
                        .tracking(-0.4)
                        .foregroundColor(Color.appForeground)
                    Text(entry.result)
                        .font(.system(size: 14, weight: .semibold))
                        .tracking(-0.28)
                        .foregroundColor(Color.appForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }
}

// MARK: - Home Empty State

struct HomeEmptyState: View {
    var onAnalyzeTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "newspaper")
                .font(.system(size: 56))
                .foregroundColor(Color.appForeground.opacity(0.3))
            Text("No analyses yet.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.appForeground)
            Text("Paste a link and choose your criteria to get started.")
                .font(.system(size: 14))
                .foregroundColor(Color.appSubtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: onAnalyzeTap) {
                Text("Analyze a Link")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appBackground)
                    .frame(height: 50)
                    .padding(.horizontal, 32)
                    .background(Color.appForeground)
                    .cornerRadius(8)
            }
            Spacer()
        }
    }
}
