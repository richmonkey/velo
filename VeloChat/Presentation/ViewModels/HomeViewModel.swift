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
    private let fetchConversation: FetchConversationUseCase
    private let setupPushNotifications: SetupPushNotificationsUseCase
    private let syncPushSubscriptions: SyncPushSubscriptionsUseCase
    private let streamAllMessages: StreamAllMessagesUseCase
    private let unreadCountStore: UnreadCountRepositoryProtocol
    private let noteRepository: ConversationNoteRepositoryProtocol
    private let memberNicknameStore: MemberNicknameStoring
    private var streamTask: Task<Void, Never>?

    init(
        fetchConversations: FetchConversationsUseCase,
        fetchConversation: FetchConversationUseCase,
        setupPushNotifications: SetupPushNotificationsUseCase,
        syncPushSubscriptions: SyncPushSubscriptionsUseCase,
        streamAllMessages: StreamAllMessagesUseCase,
        unreadCountStore: UnreadCountRepositoryProtocol,
        noteRepository: ConversationNoteRepositoryProtocol,
        memberNicknameStore: MemberNicknameStoring
    ) {
        self.fetchConversations = fetchConversations
        self.fetchConversation = fetchConversation
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
                    await updateConversation(event.conversationId)
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
            let items = rawItems.map { conversation in
                resolvedSummary(for: conversation, title: resolvedTitle(for: conversation, note: notes[conversation.id]))
            }
            viewState = items.isEmpty ? .empty : .loaded(items)
            try? await syncPushSubscriptions.execute(conversationIds: items.map(\.id))
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    private func updateConversation(_ conversationId: String) async {
        guard case .loaded(var items) = viewState else {
            await load()
            return
        }

        do {
            guard let fetched = try await fetchConversation.execute(conversationId: conversationId) else {
                if let index = items.firstIndex(where: { $0.id == conversationId }) {
                    items.remove(at: index)
                    viewState = items.isEmpty ? .empty : .loaded(items)
                    try? await syncPushSubscriptions.execute(conversationIds: items.map(\.id))
                }
                return
            }

            let note = noteRepository.note(forConversationId: conversationId)
            let resolved = resolvedSummary(for: fetched, title: resolvedTitle(for: fetched, note: note))

            if let index = items.firstIndex(where: { $0.id == conversationId }) {
                items[index] = resolved
            } else {
                items.append(resolved)
            }
            items.sort { $0.lastActivityDate > $1.lastActivityDate }

            viewState = .loaded(items)
            try? await syncPushSubscriptions.execute(conversationIds: items.map(\.id))
        } catch {
            // Best-effort: leave the existing viewState untouched on a transient single-conversation fetch failure.
        }
    }

    private func resolvedSummary(for conversation: ConversationSummary, title: String) -> ConversationSummary {
        ConversationSummary(
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

    private func resolvedTitle(for conversation: ConversationSummary, note: String?) -> String {
        if conversation.kind == .dm, let note, !note.isEmpty {
            return note
        }
        return conversation.title
    }

    private func resolvedPreview(for conversation: ConversationSummary) -> String? {
        guard let preview = conversation.lastMessagePreview, preview.contains("{{actor}}") else {
            return conversation.lastMessagePreview
        }
        let actor = conversation.lastMessageIsFromMe
            ? "Me"
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
