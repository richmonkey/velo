import Foundation

protocol MemberNicknameStoring {
    func nickname(forConversationId conversationId: String, inboxId: String) -> String?
    func nicknames(forConversationId conversationId: String) -> [String: String]
    func setNickname(_ nickname: String, forConversationId conversationId: String, inboxId: String)
}

final class MemberNicknameStore: MemberNicknameStoring {
    private let defaults = UserDefaults.standard
    private let storageKey = "velo.group_member_nicknames"

    func nickname(forConversationId conversationId: String, inboxId: String) -> String? {
        nicknames(forConversationId: conversationId)[inboxId]
    }

    func nicknames(forConversationId conversationId: String) -> [String: String] {
        loadAll()[conversationId] ?? [:]
    }

    func setNickname(_ nickname: String, forConversationId conversationId: String, inboxId: String) {
        var all = loadAll()
        var perGroup = all[conversationId] ?? [:]
        perGroup[inboxId] = nickname
        all[conversationId] = perGroup
        defaults.set(all, forKey: storageKey)
    }

    private func loadAll() -> [String: [String: String]] {
        defaults.dictionary(forKey: storageKey) as? [String: [String: String]] ?? [:]
    }
}
