import Foundation

@MainActor
final class ConversationSettingsViewModel: ObservableObject {
    @Published var note: String
    @Published private(set) var isMuted: Bool

    private let conversationId: String
    private let peerInboxId: String?
    private let noteRepository: ConversationNoteRepositoryProtocol
    private let mutedConversationStore: MutedConversationStoring
    private let setConversationMutedUseCase: SetConversationMutedUseCase

    init(
        conversationId: String,
        peerInboxId: String?,
        noteRepository: ConversationNoteRepositoryProtocol,
        mutedConversationStore: MutedConversationStoring,
        setConversationMuted: SetConversationMutedUseCase
    ) {
        self.conversationId = conversationId
        self.peerInboxId = peerInboxId
        self.noteRepository = noteRepository
        self.mutedConversationStore = mutedConversationStore
        self.setConversationMutedUseCase = setConversationMuted
        self.note = noteRepository.note(forConversationId: conversationId) ?? ""
        self.isMuted = mutedConversationStore.isMuted(conversationId: conversationId)
    }

    func refresh() {
        note = noteRepository.note(forConversationId: conversationId) ?? ""
        isMuted = mutedConversationStore.isMuted(conversationId: conversationId)
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        Task { try? await setConversationMutedUseCase.execute(conversationId: conversationId, isMuted: muted) }
    }

    func save() {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            noteRepository.removeNote(forConversationId: conversationId)
            if let peerInboxId { noteRepository.removeNote(forInboxId: peerInboxId) }
        } else {
            noteRepository.setNote(trimmed, forConversationId: conversationId)
            if let peerInboxId { noteRepository.setNote(trimmed, forInboxId: peerInboxId) }
        }
    }
}
