import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    private var preferencesStore: AppPreferencesStoring

    init(preferencesStore: AppPreferencesStoring) {
        self.preferencesStore = preferencesStore
    }

    func completeOnboarding() {
        preferencesStore.hasCompletedOnboarding = true
    }
}
