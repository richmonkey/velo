import SwiftUI

struct RootView: View {
    @StateObject private var loadingViewModel = AppDI.shared.makeLoadingViewModel()
    @State private var hasCompletedOnboarding = AppDI.shared.appPreferencesStore.hasCompletedOnboarding

    var body: some View {
        switch loadingViewModel.viewState {
        case .ready:
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        default:
            LoadingView(viewModel: loadingViewModel)
        }
    }
}

#Preview {
    RootView()
}
