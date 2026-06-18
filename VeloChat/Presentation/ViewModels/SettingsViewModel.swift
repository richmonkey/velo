import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    private var preferencesStore: AppPreferencesStoring

    init(preferencesStore: AppPreferencesStoring) {
        self.preferencesStore = preferencesStore
    }

    func resetOnboarding() {
        preferencesStore.hasCompletedOnboarding = false
    }
}
