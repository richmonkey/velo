import Foundation

@MainActor
final class MyNicknameEditViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let conversationId: String
    private let fetchGroupMembers: FetchGroupMembersUseCase
    private let updateMyNickname: UpdateMyNicknameUseCase

    init(
        conversationId: String,
        fetchGroupMembers: FetchGroupMembersUseCase,
        updateMyNickname: UpdateMyNicknameUseCase
    ) {
        self.conversationId = conversationId
        self.fetchGroupMembers = fetchGroupMembers
        self.updateMyNickname = updateMyNickname
    }

    func didLoad() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let members = try await fetchGroupMembers.execute(conversationId: conversationId)
            nickname = members.first(where: \.isMe)?.nickname ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func save() async -> Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        do {
            try await updateMyNickname.execute(conversationId: conversationId, nickname: trimmed)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
