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
    @Published private(set) var unreadCounts: [String: Int] = [:]

    private let fetchConversations: FetchConversationsUseCase
    private let setupPushNotifications: SetupPushNotificationsUseCase
    private let syncPushSubscriptions: SyncPushSubscriptionsUseCase
    private let streamAllMessages: StreamAllMessagesUseCase
    private let unreadCountStore: UnreadCountRepositoryProtocol
    private let noteRepository: ConversationNoteRepositoryProtocol
    private var streamTask: Task<Void, Never>?

    init(
        fetchConversations: FetchConversationsUseCase,
        setupPushNotifications: SetupPushNotificationsUseCase,
        syncPushSubscriptions: SyncPushSubscriptionsUseCase,
        streamAllMessages: StreamAllMessagesUseCase,
        unreadCountStore: UnreadCountRepositoryProtocol,
        noteRepository: ConversationNoteRepositoryProtocol
    ) {
        self.fetchConversations = fetchConversations
        self.setupPushNotifications = setupPushNotifications
        self.syncPushSubscriptions = syncPushSubscriptions
        self.streamAllMessages = streamAllMessages
        self.unreadCountStore = unreadCountStore
        self.noteRepository = noteRepository
    }

    func didLoad() {
        Task { await load() }
        Task { _ = try? await setupPushNotifications.execute() }
        startStreaming()
    }

    func refresh() async {
        await load()
    }

    func refreshUnreadCounts() {
        unreadCounts = unreadCountStore.loadAll()
    }

    func stopStreaming() {
        streamTask?.cancel()
        streamTask = nil
    }

    private func startStreaming() {
        streamTask = Task {
            do {
                for try await conversationId in streamAllMessages.execute() {
                    unreadCountStore.increment(conversationId: conversationId)
                    unreadCounts = unreadCountStore.loadAll()
                    await load()
                }
            } catch {
                // Stream is best-effort; manual refresh via pull-to-refresh still works.
            }
        }
    }

    private func load() async {
        do {
            let rawItems = try await fetchConversations.execute()
            let notes = noteRepository.loadAll()
            let items = rawItems.map { conversation -> ConversationSummary in
                guard conversation.kind == .dm,
                      let note = notes[conversation.id], !note.isEmpty
                else { return conversation }
                return ConversationSummary(
                    id: conversation.id,
                    kind: conversation.kind,
                    title: note,
                    lastMessagePreview: conversation.lastMessagePreview,
                    lastActivityDate: conversation.lastActivityDate
                )
            }
            viewState = items.isEmpty ? .empty : .loaded(items)
            try? await syncPushSubscriptions.execute(conversationIds: items.map(\.id))
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}
