import SwiftUI

final class ThemeManager: ObservableObject {
    @Published var mode: ThemeMode {
        didSet {
            preferencesStore.themeMode = mode
        }
    }

    private var preferencesStore: AppPreferencesStoring

    init(preferencesStore: AppPreferencesStoring) {
        self.preferencesStore = preferencesStore
        self.mode = preferencesStore.themeMode
    }

    var colorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
