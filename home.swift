import SwiftUI
import UIKit

// MARK: - Home View

struct HomeView: View {
    var onAnalyzeTap: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "App name")

            if let entry = appState.history.first {
                HomeResultContent(entry: entry)
            } else {
                HomeEmptyState(onAnalyzeTap: onAnalyzeTap)
            }
        }
        .background(Color.appBackground)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 69) }
    }
}

// MARK: - Home Result Content

struct HomeResultContent: View {
    let entry: HistoryEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                thumbnailSection
                sourceSection
                diagnosisSection
            }
        }
    }

    private var thumbnailSection: some View {
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
                    .foregroundStyle(Color.appForeground.opacity(0.3))
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.appDivider).frame(height: 0.5)
        }
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !entry.channelOrSource.isEmpty {
                Text(entry.channelOrSource)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appForeground)
            }
            Text(entry.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appForeground)
                .underline()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.appDivider).frame(height: 0.5)
        }
    }

    private var diagnosisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Diagnosis:")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(Color.appForeground)
            Text(entry.result)
                .font(.system(size: 14, weight: .semibold))
                .tracking(-0.28)
                .foregroundStyle(Color.appForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
                .foregroundStyle(Color.appForeground.opacity(0.3))
            Text("No analyses yet.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.appForeground)
            Text("Paste a link and choose your criteria to get started.")
                .font(.system(size: 14))
                .foregroundStyle(Color.appSubtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: onAnalyzeTap) {
                Text("Analyze a Link")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appBackground)
                    .frame(height: 50)
                    .padding(.horizontal, 32)
                    .background(Color.appForeground)
                    .cornerRadius(8)
            }
            Spacer()
        }
    }
}
