import SwiftUI

struct RootView: View {
    @StateObject private var loadingViewModel = AppDI.shared.makeLoadingViewModel()

    var body: some View {
        switch loadingViewModel.viewState {
        case .ready:
            HomeView()
        default:
            LoadingView(viewModel: loadingViewModel)
        }
    }
}

#Preview {
    RootView()
}
