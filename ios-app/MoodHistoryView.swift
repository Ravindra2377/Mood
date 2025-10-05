import SwiftUI

public struct MoodHistoryView: View {
    @StateObject var vm: MoodHistoryViewModel
    @State private var showingDetail: Bool = false
    @State private var selectedEntry: MoodEntryModel?

    public init(viewModel: MoodHistoryViewModel? = nil) {
        if let vm = viewModel {
            _vm = StateObject(wrappedValue: vm)
        } else {
            _vm = StateObject(wrappedValue: MoodHistoryViewModel())
        }
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(vm.entries) { entry in
                    Button(action: {
                        selectedEntry = entry
                        showingDetail = true
                    }) {
                        HStack {
                            Text(emoji(for: entry.rating)).font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text(entry.note ?? "—").lineLimit(1)
                                Text(entry.timestamp, style: .date).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            if !entry.synced { Text("Unsynced").font(.caption).foregroundColor(.orange) }
                        }
                    }
                    .onAppear {
                        // pagination trigger
                        if vm.entries.last == entry {
                            vm.loadNextPage()
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Mood History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { vm.refresh() }) { Image(systemName: "arrow.clockwise") }
                }
            }
            .sheet(isPresented: $showingDetail) {
                if let selected = selectedEntry {
                    MoodDetailView(entry: selected, onSave: { note, rating in
                        vm.update(id: selected.id, newNote: note, newRating: rating) { _ in }
                        showingDetail = false
                    }, onDelete: {
                        vm.delete(id: selected.id) { _ in }
                        showingDetail = false
                    })
                }
            }
            .onAppear {
                vm.loadFirstPage()
            }
        }
    }

    private func emoji(for rating: Int) -> String {
        switch rating {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "🙂"
        case 4: return "😃"
        default: return "🤩"
        }
    }

    private func delete(at offsets: IndexSet) {
        for idx in offsets {
            let entry = vm.entries[idx]
            vm.delete(id: entry.id) { _ in }
        }
    }
}

#if DEBUG
struct MoodHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        MoodHistoryView()
    }
}
#endif
