import SwiftUI

@main
struct VeloChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @ObservedObject private var themeManager = AppDI.shared.themeManager

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Color.brandPrimary)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
