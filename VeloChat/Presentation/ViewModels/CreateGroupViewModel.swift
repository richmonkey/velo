import Foundation

struct DMContactItem: Identifiable, Hashable {
    let id: String           // conversation id
    let peerInboxId: String  // the actual inbox id, used to create the group
    let displayName: String  // note name, or abbreviated id
}

@MainActor
final class CreateGroupViewModel: ObservableObject {
    @Published private(set) var contacts: [DMContactItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isCreating = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var createdConversation: ConversationSummary?
    @Published var selectedIds: Set<String> = []
    @Published var groupName: String = ""

    var canProceed: Bool { !selectedIds.isEmpty }
    var canCreate: Bool { !groupName.trimmingCharacters(in: .whitespaces).isEmpty }

    private let fetchConversations: FetchConversationsUseCase
    private let noteRepository: ConversationNoteRepositoryProtocol
    private let createGroupUseCase: CreateGroupUseCase

    init(
        fetchConversations: FetchConversationsUseCase,
        noteRepository: ConversationNoteRepositoryProtocol,
        createGroup: CreateGroupUseCase
    ) {
        self.fetchConversations = fetchConversations
        self.noteRepository = noteRepository
        self.createGroupUseCase = createGroup
    }

    func didLoad() {
        Task { await loadContacts() }
    }

    func toggle(contactId: String) {
        if selectedIds.contains(contactId) {
            selectedIds.remove(contactId)
        } else {
            selectedIds.insert(contactId)
        }
    }

    func createGroup() {
        let name = groupName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let peerInboxIds = contacts
            .filter { selectedIds.contains($0.id) }
            .map(\.peerInboxId)
        guard !peerInboxIds.isEmpty else { return }

        isCreating = true
        errorMessage = nil
        Task {
            defer { isCreating = false }
            do {
                createdConversation = try await createGroupUseCase.execute(name: name, peerInboxIds: peerInboxIds)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func loadContacts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let conversations = try await fetchConversations.execute()
            let notes = noteRepository.loadAll()
            contacts = conversations
                .filter { $0.kind == .dm }
                .compactMap { conversation -> DMContactItem? in
                    guard let peerInboxId = conversation.peerInboxId else { return nil }
                    let note = notes[conversation.id] ?? ""
                    let displayName = note.isEmpty ? conversation.title : note
                    return DMContactItem(
                        id: conversation.id,
                        peerInboxId: peerInboxId,
                        displayName: displayName
                    )
                }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
