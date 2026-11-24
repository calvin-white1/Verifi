import SwiftUI
import UIKit

// MARK: - History Entry Model

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let result: String
    let channelOrSource: String
    let url: String
    let criteriaFlags: CriteriaFlags
    var thumbnailData: Data?

    var thumbnailImage: UIImage? {
        thumbnailData.flatMap { UIImage(data: $0) }
    }

    struct CriteriaFlags: Codable {
        var biasDetection: Bool
        var aiDetection: Bool
        var factChecking: Bool
    }

    init(title: String,
         result: String,
         channelOrSource: String,
         thumbnailImage: UIImage?,
         criteria: AnalysisCriteria,
         url: String) {
        self.id = UUID()
        self.title = title
        self.result = result
        self.channelOrSource = channelOrSource
        self.url = url
        self.criteriaFlags = CriteriaFlags(
            biasDetection: criteria.biasDetection,
            aiDetection: criteria.aiDetection,
            factChecking: criteria.factChecking
        )
        self.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.6)
    }
}

// MARK: - History View

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var editMode: EditMode = .inactive

    var body: some View {
        VStack(spacing: 0) {
            historyHeader
            historyContent
        }
        .background(Color.appBackground)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 69) }
    }

    private var historyHeader: some View {
        ZStack {
            Text("History")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(Color.appForeground)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                if !appState.history.isEmpty {
                    Button(editMode == .active ? "Done" : "Edit") {
                        editMode = editMode == .active ? .inactive : .active
                    }
                    .font(.system(size: 15))
                    .foregroundStyle(Color.appForeground)
                    .padding(.leading, 16)
                }
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

    @ViewBuilder
    private var historyContent: some View {
        if appState.history.isEmpty {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "clock")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.appForeground.opacity(0.3))
                Text("No analyses yet.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appSubtle)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            List {
                ForEach(appState.history) { entry in
                    HistoryRow(entry: entry)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.appBackground)
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            .background(Color.appBackground)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, $editMode)
        }
    }

    private func delete(at offsets: IndexSet) {
        appState.history.remove(atOffsets: offsets)
        HistoryStore.save(appState.history)
    }
}

// MARK: - History Row

struct HistoryRow: View {
    let entry: HistoryEntry

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.4)
                    .foregroundStyle(Color.appForeground)
                    .lineLimit(1)

                Text(entry.result)
                    .font(.system(size: 14, weight: .medium))
                    .tracking(-0.28)
                    .foregroundStyle(Color.appForeground)
                    .lineLimit(2)

                if !entry.channelOrSource.isEmpty {
                    Text(entry.channelOrSource)
                        .font(.system(size: 13, weight: .medium))
                        .tracking(-0.26)
                        .foregroundStyle(Color.appSubtle)
                        .lineLimit(1)
                }

                CriteriaTags(flags: entry.criteriaFlags)
            }
            .padding(.leading, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            thumbnailView
                .frame(width: 133, height: 79)
                .clipped()
                .padding(.vertical, 14)
        }
        .frame(minHeight: 108)
        .background(Color.appBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appDivider)
                .frame(height: 0.5)
        }
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let img = entry.thumbnailImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        } else {
            Color.appCard
                .overlay(alignment: .center) {
                    Image(systemName: "photo")
                        .foregroundStyle(Color.appForeground.opacity(0.3))
                }
        }
    }
}

// MARK: - Criteria Tags

struct CriteriaTags: View {
    let flags: HistoryEntry.CriteriaFlags

    var body: some View {
        HStack(spacing: 4) {
            if flags.biasDetection { criteriaTag("Bias") }
            if flags.aiDetection   { criteriaTag("AI") }
            if flags.factChecking  { criteriaTag("Facts") }
        }
    }

    @ViewBuilder
    private func criteriaTag(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color.appForeground)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.appCard)
            .cornerRadius(4)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.appDivider, lineWidth: 0.5)
            }
    }
}
