import SwiftUI
import SwiftData

@main
struct YourAppName: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
        .modelContainer(for: User.self)
    }
}
