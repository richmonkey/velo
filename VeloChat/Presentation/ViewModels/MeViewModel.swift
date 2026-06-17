import Foundation

enum MeViewState {
    case loading
    case loaded(XMTPIdentity)
    case error(String)
}

@MainActor
final class MeViewModel: ObservableObject {
    @Published private(set) var viewState: MeViewState = .loading

    private let initializeXMTPClient: InitializeXMTPClientUseCase

    init(initializeXMTPClient: InitializeXMTPClientUseCase) {
        self.initializeXMTPClient = initializeXMTPClient
    }

    func didLoad() {
        Task {
            do {
                let identity = try await initializeXMTPClient.execute()
                viewState = .loaded(identity)
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
