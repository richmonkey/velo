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
    private let memberNicknameStore: MemberNicknameStoring
    private var streamTask: Task<Void, Never>?

    init(
        fetchConversations: FetchConversationsUseCase,
        setupPushNotifications: SetupPushNotificationsUseCase,
        syncPushSubscriptions: SyncPushSubscriptionsUseCase,
        streamAllMessages: StreamAllMessagesUseCase,
        unreadCountStore: UnreadCountRepositoryProtocol,
        noteRepository: ConversationNoteRepositoryProtocol,
        memberNicknameStore: MemberNicknameStoring
    ) {
        self.fetchConversations = fetchConversations
        self.setupPushNotifications = setupPushNotifications
        self.syncPushSubscriptions = syncPushSubscriptions
        self.streamAllMessages = streamAllMessages
        self.unreadCountStore = unreadCountStore
        self.noteRepository = noteRepository
        self.memberNicknameStore = memberNicknameStore
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
                for try await event in streamAllMessages.execute() {
                    if let update = event.nicknameUpdate {
                        memberNicknameStore.setNickname(update.nickname, forConversationId: event.conversationId, inboxId: update.inboxId)
                    }
                    if !event.isFromMe {
                        unreadCountStore.increment(conversationId: event.conversationId)
                        unreadCounts = unreadCountStore.loadAll()
                    }
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
                let title: String
                if conversation.kind == .dm, let note = notes[conversation.id], !note.isEmpty {
                    title = note
                } else {
                    title = conversation.title
                }
                return ConversationSummary(
                    id: conversation.id,
                    kind: conversation.kind,
                    title: title,
                    lastMessagePreview: resolvedPreview(for: conversation),
                    lastActivityDate: conversation.lastActivityDate,
                    peerInboxId: conversation.peerInboxId,
                    lastMessageSenderInboxId: conversation.lastMessageSenderInboxId,
                    lastMessageIsFromMe: conversation.lastMessageIsFromMe
                )
            }
            viewState = items.isEmpty ? .empty : .loaded(items)
            try? await syncPushSubscriptions.execute(conversationIds: items.map(\.id))
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    private func resolvedPreview(for conversation: ConversationSummary) -> String? {
        guard let preview = conversation.lastMessagePreview, preview.contains("{{actor}}") else {
            return conversation.lastMessagePreview
        }
        let actor = conversation.lastMessageIsFromMe
            ? "我"
            : displayName(forInboxId: conversation.lastMessageSenderInboxId ?? "", conversationId: conversation.id)
        return preview.replacingOccurrences(of: "{{actor}}", with: actor)
    }

    private func displayName(forInboxId inboxId: String, conversationId: String) -> String {
        if let nickname = memberNicknameStore.nickname(forConversationId: conversationId, inboxId: inboxId), !nickname.isEmpty {
            return nickname
        }
        if let note = noteRepository.note(forInboxId: inboxId), !note.isEmpty {
            return note
        }
        guard inboxId.count > 10 else { return inboxId }
        return "\(inboxId.prefix(6))…\(inboxId.suffix(4))"
    }
}
