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
    private let syncAllConversations: SyncAllConversationsUseCase
    private var preferencesStore: AppPreferencesStoring

    init(
        initializeXMTPClient: InitializeXMTPClientUseCase,
        syncAllConversations: SyncAllConversationsUseCase,
        preferencesStore: AppPreferencesStoring
    ) {
        self.initializeXMTPClient = initializeXMTPClient
        self.syncAllConversations = syncAllConversations
        self.preferencesStore = preferencesStore
    }

    func didLoad() {
        Task {
            do {
                let identity = try await initializeXMTPClient.execute()
                if !preferencesStore.hasCompletedInitialSync {
                    try await syncAllConversations.execute()
                    preferencesStore.hasCompletedInitialSync = true
                }
                viewState = .ready(identity)
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
