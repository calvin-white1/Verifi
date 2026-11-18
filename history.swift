import SwiftUI

// MARK: - History Entry Model

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let result: String
    let channelOrSource: String
    // Thumbnail stored as base64 JPEG for Codable persistence
    private var thumbnailData: Data?

    // Computed convenience for UI
    var thumbnailImage: UIImage? {
        get { thumbnailData.flatMap { UIImage(data: $0) } }
    }

    init(title: String, result: String, channelOrSource: String, thumbnailImage: UIImage?) {
        self.id = UUID()
        self.title = title
        self.result = result
        self.channelOrSource = channelOrSource
        self.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.6)
    }
}

// MARK: - History View

struct HistoryView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            Group {
                if appState.history.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No analyses yet.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(appState.history) { entry in
                            HistoryRow(entry: entry)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HamburgerMenuButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
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
            // Text block
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.4)
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(entry.result)
                    .font(.system(size: 14, weight: .medium))
                    .tracking(-0.28)
                    .foregroundColor(.black)
                    .lineLimit(2)

                if !entry.channelOrSource.isEmpty {
                    Text(entry.channelOrSource)
                        .font(.system(size: 13, weight: .medium))
                        .tracking(-0.26)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding(.leading, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Thumbnail
            Group {
                if let img = entry.thumbnailImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(hex: "#d9d9d9")
                }
            }
            .frame(width: 133, height: 79)
            .clipped()
            .padding(.vertical, 14)
        }
        .frame(height: 108)
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(Color.black.opacity(0.2), lineWidth: 0.5),
            alignment: .bottom
        )
    }
}