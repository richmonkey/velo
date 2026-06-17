import Foundation

struct ChatMessage: Identifiable, Equatable {
    struct NicknameUpdate: Equatable {
        let inboxId: String
        let nickname: String
    }

    let id: String
    let text: String
    let isFromMe: Bool
    let isSystemNotice: Bool
    let senderInboxId: String
    let nicknameUpdate: NicknameUpdate?
    let imageData: Data?
    let audioData: Data?
    let audioDuration: TimeInterval?
    let sentAt: Date
    let sentAtNs: Int64
}
