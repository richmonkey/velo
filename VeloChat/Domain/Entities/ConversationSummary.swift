import Foundation

struct ConversationSummary: Identifiable, Hashable {
    enum Kind: Hashable {
        case group
        case dm
    }

    let id: String
    let kind: Kind
    let title: String
    let lastMessagePreview: String?
    let lastActivityDate: Date
    let peerInboxId: String?   // DM-only; nil for groups
    let lastMessageSenderInboxId: String?
    let lastMessageIsFromMe: Bool
}
