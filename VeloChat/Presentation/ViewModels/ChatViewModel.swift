import Foundation

enum ChatViewState {
    case loading
    case loaded([ChatMessage])
    case error(String)
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var viewState: ChatViewState = .loading
    @Published private(set) var isSending = false

    let conversationId: String
    @Published private(set) var conversationTitle: String
    let kind: ConversationSummary.Kind

    @Published private(set) var nicknameByInboxId: [String: String] = [:]

    private let defaultTitle: String
    private let fetchMessages: FetchMessagesUseCase
    private let sendMessage: SendMessageUseCase
    private let streamMessages: StreamMessagesUseCase
    private let unreadCountStore: UnreadCountRepositoryProtocol
    private let noteRepository: ConversationNoteRepositoryProtocol
    private let fetchGroupMembers: FetchGroupMembersUseCase
    private let fetchGroupInfo: FetchGroupInfoUseCase
    private var streamTask: Task<Void, Never>?

    init(
        conversationId: String,
        conversationTitle: String,
        kind: ConversationSummary.Kind,
        fetchMessages: FetchMessagesUseCase,
        sendMessage: SendMessageUseCase,
        streamMessages: StreamMessagesUseCase,
        unreadCountStore: UnreadCountRepositoryProtocol,
        noteRepository: ConversationNoteRepositoryProtocol,
        fetchGroupMembers: FetchGroupMembersUseCase,
        fetchGroupInfo: FetchGroupInfoUseCase
    ) {
        self.conversationId = conversationId
        self.conversationTitle = conversationTitle
        self.defaultTitle = conversationTitle
        self.kind = kind
        self.fetchMessages = fetchMessages
        self.sendMessage = sendMessage
        self.streamMessages = streamMessages
        self.unreadCountStore = unreadCountStore
        self.noteRepository = noteRepository
        self.fetchGroupMembers = fetchGroupMembers
        self.fetchGroupInfo = fetchGroupInfo
    }

    func refreshTitle() {
        if kind == .group {
            Task { await refreshGroupTitle() }
            return
        }
        let note = noteRepository.note(forConversationId: conversationId) ?? ""
        conversationTitle = note.isEmpty ? defaultTitle : note
    }

    private func refreshGroupTitle() async {
        do {
            let info = try await fetchGroupInfo.execute(conversationId: conversationId)
            conversationTitle = info.name
        } catch {
            // Best-effort: keep showing whatever title we already have.
        }
    }

    func didLoad() {
        unreadCountStore.reset(conversationId: conversationId)
        Task { await load() }
        startStreaming()
        if kind == .group {
            Task { await loadMembers() }
        }
    }

    func displayName(forInboxId inboxId: String) -> String {
        if let nickname = nicknameByInboxId[inboxId], !nickname.isEmpty {
            return nickname
        }
        guard inboxId.count > 10 else { return inboxId }
        return "\(inboxId.prefix(6))…\(inboxId.suffix(4))"
    }

    func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSending = true
        Task {
            defer { isSending = false }
            do {
                let message = try await sendMessage.execute(conversationId: conversationId, text: trimmed)
                appendIfNeeded(message)
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    func stopStreaming() {
        unreadCountStore.reset(conversationId: conversationId)
        streamTask?.cancel()
        streamTask = nil
    }

    private func load() async {
        do {
            let messages = try await fetchMessages.execute(conversationId: conversationId)
            for message in messages {
                if let update = message.nicknameUpdate {
                    nicknameByInboxId[update.inboxId] = update.nickname
                }
            }
            viewState = .loaded(messages)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    private func loadMembers() async {
        do {
            let members = try await fetchGroupMembers.execute(conversationId: conversationId)
            for member in members {
                if let nickname = member.nickname {
                    nicknameByInboxId[member.id] = nickname
                }
            }
        } catch {
            // Best-effort: sender labels just fall back to abbreviated inbox ids.
        }
    }

    private func startStreaming() {
        streamTask = Task {
            do {
                for try await message in streamMessages.execute(conversationId: conversationId) {
                    appendIfNeeded(message)
                }
            } catch {
                // Live updates are best-effort; the initial load already surfaced any hard failure.
            }
        }
    }

    private func appendIfNeeded(_ message: ChatMessage) {
        if let update = message.nicknameUpdate {
            nicknameByInboxId[update.inboxId] = update.nickname
        }
        guard case .loaded(var messages) = viewState else {
            viewState = .loaded([message])
            return
        }
        guard !messages.contains(where: { $0.id == message.id }) else { return }
        messages.append(message)
        viewState = .loaded(messages)
    }
}
