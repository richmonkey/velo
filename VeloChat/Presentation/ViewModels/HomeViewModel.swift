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
    private let streamAllMessages: StreamAllMessagesUseCase
    private var streamTask: Task<Void, Never>?

    init(
        fetchConversations: FetchConversationsUseCase,
        setupPushNotifications: SetupPushNotificationsUseCase,
        syncPushSubscriptions: SyncPushSubscriptionsUseCase,
        streamAllMessages: StreamAllMessagesUseCase
    ) {
        self.fetchConversations = fetchConversations
        self.setupPushNotifications = setupPushNotifications
        self.syncPushSubscriptions = syncPushSubscriptions
        self.streamAllMessages = streamAllMessages
    }

    func didLoad() {
        Task { await load() }
        Task { _ = try? await setupPushNotifications.execute() }
        startStreaming()
    }

    func refresh() async {
        await load()
    }

    func stopStreaming() {
        streamTask?.cancel()
        streamTask = nil
    }

    private func startStreaming() {
        streamTask = Task {
            do {
                for try await _ in streamAllMessages.execute() {
                    await load()
                }
            } catch {
                // Stream is best-effort; manual refresh via pull-to-refresh still works.
            }
        }
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
