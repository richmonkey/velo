import SwiftUI

struct RootView: View {
    @StateObject private var loadingViewModel = AppDI.shared.makeLoadingViewModel()
    @State private var hasCompletedOnboarding = AppDI.shared.appPreferencesStore.hasCompletedOnboarding

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        } else {
            switch loadingViewModel.viewState {
            case .ready:
                HomeView()
            default:
                LoadingView(viewModel: loadingViewModel)
            }
        }
    }
}

#Preview {
    RootView()
}
