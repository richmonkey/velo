import Foundation

final class AppPreferencesStore: AppPreferencesStoring {
    private let defaults = UserDefaults.standard
    private let themeModeKey = "velo.theme_mode"
    private let onboardingKey = "velo.has_completed_onboarding"
    private let initialSyncKey = "velo.has_completed_initial_sync"

    var themeMode: ThemeMode {
        get {
            (defaults.string(forKey: themeModeKey)).flatMap(ThemeMode.init(rawValue:)) ?? .system
        }
        set {
            defaults.set(newValue.rawValue, forKey: themeModeKey)
        }
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: onboardingKey) }
        set { defaults.set(newValue, forKey: onboardingKey) }
    }

    var hasCompletedInitialSync: Bool {
        get { defaults.bool(forKey: initialSyncKey) }
        set { defaults.set(newValue, forKey: initialSyncKey) }
    }
}
