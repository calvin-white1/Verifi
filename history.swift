import SwiftUI

// MARK: - History Entry Model

struct HistoryEntry: Identifiable {
    let id = UUID()
    let title: String
    let result: String       // e.g. "Biased" / "Not biased"
    let channelOrSource: String
    let thumbnailName: String?   // local asset name, nil shows grey placeholder
}

// MARK: - History View

struct HistoryView: View {

    // Sample entries that match the Figma design placeholders
    @State private var entries: [HistoryEntry] = [
        HistoryEntry(title: "Video name",    result: "Biased/not biased", channelOrSource: "Channel name", thumbnailName: "home_thumbnail"),
        HistoryEntry(title: "News story",    result: "Biased/not biased", channelOrSource: "News station",  thumbnailName: nil),
        HistoryEntry(title: "Image name or #", result: "Biased/not biased", channelOrSource: "",           thumbnailName: nil),
        HistoryEntry(title: "Entry 4",       result: "Biased/not biased", channelOrSource: "",             thumbnailName: nil),
        HistoryEntry(title: "Entry 5",       result: "Biased/not biased", channelOrSource: "",             thumbnailName: nil),
        HistoryEntry(title: "Entry 6",       result: "Biased/not biased", channelOrSource: "",             thumbnailName: nil),
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(entries) { entry in
                    HistoryRow(entry: entry)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
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
        entries.remove(atOffsets: offsets)
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
                    .font(.system(size: 16, weight: .medium))
                    .tracking(-0.32)
                    .foregroundColor(.black)
                    .lineLimit(2)

                if !entry.channelOrSource.isEmpty {
                    Text(entry.channelOrSource)
                        .font(.system(size: 15, weight: .medium))
                        .tracking(-0.3)
                        .foregroundColor(.black)
                        .lineLimit(1)
                }
            }
            .padding(.leading, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Thumbnail
            Group {
                if let name = entry.thumbnailName, let img = UIImage(named: name) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(hex: "#d9d9d9")
                }
            }
            .frame(width: 133, height: 79)
            .clipped()
            .padding(.trailing, 0)
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
