import Foundation

enum HomeViewState {
    case loading
    case loaded([ConversationSummary])
    case empty
    case error(String)
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var viewState: HomeViewState = .loading

    private let fetchConversations: FetchConversationsUseCase
    private let setupPushNotifications: SetupPushNotificationsUseCase
    private let syncPushSubscriptions: SyncPushSubscriptionsUseCase

    init(
        fetchConversations: FetchConversationsUseCase,
        setupPushNotifications: SetupPushNotificationsUseCase,
        syncPushSubscriptions: SyncPushSubscriptionsUseCase
    ) {
        self.fetchConversations = fetchConversations
        self.setupPushNotifications = setupPushNotifications
        self.syncPushSubscriptions = syncPushSubscriptions
    }

    func didLoad() {
        Task { await load() }
        Task { _ = try? await setupPushNotifications.execute() }
    }

    func refresh() async {
        await load()
    }

    private func load() async {
        do {
            let items = try await fetchConversations.execute()
            viewState = items.isEmpty ? .empty : .loaded(items)
            try? await syncPushSubscriptions.execute(conversationIds: items.map(\.id))
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}
