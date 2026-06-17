import Foundation

@MainActor
final class GroupNameEditViewModel: ObservableObject {
    @Published var name: String = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let conversationId: String
    private let fetchGroupInfo: FetchGroupInfoUseCase
    private let updateGroupName: UpdateGroupNameUseCase

    init(
        conversationId: String,
        fetchGroupInfo: FetchGroupInfoUseCase,
        updateGroupName: UpdateGroupNameUseCase
    ) {
        self.conversationId = conversationId
        self.fetchGroupInfo = fetchGroupInfo
        self.updateGroupName = updateGroupName
    }

    func didLoad() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let info = try await fetchGroupInfo.execute(conversationId: conversationId)
            name = info.name
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func save() async -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        do {
            try await updateGroupName.execute(conversationId: conversationId, name: trimmed)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
