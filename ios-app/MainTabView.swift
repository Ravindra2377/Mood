import SwiftUI

public struct MainTabView: View {
    @StateObject public var moodVM: MoodViewModel

    public init(viewModel: MoodViewModel) {
        _moodVM = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        TabView {
            MoodView(viewModel: moodVM)
                .tabItem {
                    Image(systemName: "face.smiling")
                    Text("SOUL")
                }
                .overlay(
                    Group {
                        if moodVM.unsyncedCount > 0 {
                            BadgeView(count: moodVM.unsyncedCount)
                                .offset(x: 40, y: -22)
                        }
                    }, alignment: .topTrailing
                )

            MoodHistoryView(viewModel: MoodHistoryViewModel(context: PersistenceController.shared.container.viewContext))
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
        }
    }
}

struct BadgeView: View {
    let count: Int
    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.caption2)
            .foregroundColor(.white)
            .padding(6)
            .background(Circle().fill(Color.red))
            .shadow(radius: 1)
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let client = APIClient(baseURL: URL(string: "https://api.example.com")!, tokenProvider: DefaultTokenProvider())
        MainTabView(viewModel: MoodViewModel(api: client))
    }
}
#endif
