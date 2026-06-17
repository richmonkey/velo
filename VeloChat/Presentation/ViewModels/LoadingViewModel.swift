import Foundation

enum LoadingViewState {
    case loading
    case ready(XMTPIdentity)
    case error(String)
}

@MainActor
final class LoadingViewModel: ObservableObject {
    @Published private(set) var viewState: LoadingViewState = .loading

    private let initializeXMTPClient: InitializeXMTPClientUseCase

    init(initializeXMTPClient: InitializeXMTPClientUseCase) {
        self.initializeXMTPClient = initializeXMTPClient
    }

    func didLoad() {
        Task {
            do {
                let identity = try await initializeXMTPClient.execute()
                viewState = .ready(identity)
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
