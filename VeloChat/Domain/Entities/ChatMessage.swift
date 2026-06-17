import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let text: String
    let isFromMe: Bool
    let sentAt: Date
}
