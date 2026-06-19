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
    @Published private(set) var hasMoreHistory = true
    @Published private(set) var canSendMessages = true
    @Published private(set) var disabledReason: String?
    private var groupIsActive = true
    private var groupHasOtherMembers = true
    private var isLoadingMore = false

    let conversationId: String
    let peerInboxId: String?
    @Published private(set) var conversationTitle: String
    let kind: ConversationSummary.Kind

    @Published private(set) var nicknameByInboxId: [String: String] = [:]
    private var inboxNotes: [String: String] = [:]

    private let defaultTitle: String
    private let fetchMessages: FetchMessagesUseCase
    private let sendMessage: SendMessageUseCase
    private let sendImageMessage: SendImageMessageUseCase
    private let sendVoiceMessage: SendVoiceMessageUseCase
    private let streamMessages: StreamMessagesUseCase
    private let unreadCountStore: UnreadCountRepositoryProtocol
    private let noteRepository: ConversationNoteRepositoryProtocol
    private let fetchGroupMembers: FetchGroupMembersUseCase
    private let fetchGroupInfo: FetchGroupInfoUseCase
    private var streamTask: Task<Void, Never>?

    init(
        conversationId: String,
        peerInboxId: String?,
        conversationTitle: String,
        kind: ConversationSummary.Kind,
        fetchMessages: FetchMessagesUseCase,
        sendMessage: SendMessageUseCase,
        sendImageMessage: SendImageMessageUseCase,
        sendVoiceMessage: SendVoiceMessageUseCase,
        streamMessages: StreamMessagesUseCase,
        unreadCountStore: UnreadCountRepositoryProtocol,
        noteRepository: ConversationNoteRepositoryProtocol,
        fetchGroupMembers: FetchGroupMembersUseCase,
        fetchGroupInfo: FetchGroupInfoUseCase
    ) {
        self.conversationId = conversationId
        self.peerInboxId = peerInboxId
        self.conversationTitle = conversationTitle
        self.defaultTitle = conversationTitle
        self.kind = kind
        self.fetchMessages = fetchMessages
        self.sendMessage = sendMessage
        self.sendImageMessage = sendImageMessage
        self.sendVoiceMessage = sendVoiceMessage
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
            groupIsActive = info.isActive
            updateSendability()
        } catch {
            // Best-effort: keep showing whatever title/state we already have.
        }
    }

    private func updateSendability() {
        if !groupIsActive {
            disabledReason = "You are no longer a member of this group."
        } else if !groupHasOtherMembers {
            disabledReason = "This group has been dissolved."
        } else {
            disabledReason = nil
        }
        canSendMessages = disabledReason == nil
    }

    func didLoad() {
        unreadCountStore.reset(conversationId: conversationId)
        inboxNotes = noteRepository.loadAllInboxNotes()
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
        if let note = inboxNotes[inboxId], !note.isEmpty {
            return note
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

    func sendImage(data: Data, filename: String, mimeType: String) {
        isSending = true
        Task {
            defer { isSending = false }
            do {
                let message = try await sendImageMessage.execute(conversationId: conversationId, imageData: data, filename: filename, mimeType: mimeType)
                appendIfNeeded(message)
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    func sendVoice(data: Data, filename: String, mimeType: String, duration: TimeInterval) {
        isSending = true
        Task {
            defer { isSending = false }
            do {
                let message = try await sendVoiceMessage.execute(conversationId: conversationId, audioData: data, filename: filename, mimeType: mimeType, duration: duration)
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
            let messages = try await fetchMessages.execute(conversationId: conversationId, beforeNs: nil)
            viewState = .loaded(messages)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func loadMore() async {
        guard !isLoadingMore, hasMoreHistory,
              case .loaded(let messages) = viewState,
              let oldest = messages.first else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let older = try await fetchMessages.execute(conversationId: conversationId, beforeNs: oldest.sentAtNs)
            guard !older.isEmpty else {
                hasMoreHistory = false
                return
            }
            guard case .loaded(var current) = viewState else { return }
            let existingIds = Set(current.map(\.id))
            current.insert(contentsOf: older.filter { !existingIds.contains($0.id) }, at: 0)
            viewState = .loaded(current)
        } catch {
            // Pagination failure is best-effort; keep showing what's already loaded.
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
            groupHasOtherMembers = members.contains { !$0.isMe }
            updateSendability()
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

        if kind == .group, message.isSystemNotice {
            Task {
                await refreshGroupTitle()
                await loadMembers()
            }
        }
    }
}
