import Foundation

@MainActor
final class GroupAnnouncementEditViewModel: ObservableObject {
    @Published var announcement: String = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let conversationId: String
    private let fetchGroupInfo: FetchGroupInfoUseCase
    private let updateGroupAnnouncement: UpdateGroupAnnouncementUseCase

    init(
        conversationId: String,
        fetchGroupInfo: FetchGroupInfoUseCase,
        updateGroupAnnouncement: UpdateGroupAnnouncementUseCase
    ) {
        self.conversationId = conversationId
        self.fetchGroupInfo = fetchGroupInfo
        self.updateGroupAnnouncement = updateGroupAnnouncement
    }

    func didLoad() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let info = try await fetchGroupInfo.execute(conversationId: conversationId)
            announcement = info.announcement
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func save() async -> Bool {
        do {
            try await updateGroupAnnouncement.execute(conversationId: conversationId, announcement: announcement)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
