import SwiftUI

@main
struct Unigiri_iosApp: App {
    @StateObject private var searchViewModel = SearchViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: searchViewModel)
        }
    }
}
