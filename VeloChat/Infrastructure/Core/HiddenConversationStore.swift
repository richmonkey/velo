import Foundation

final class HiddenConversationStore: HiddenConversationStoring {
    private let defaults = UserDefaults.standard
    private let storageKey = "velo.hidden_conversation_ids"

    func isHidden(conversationId: String) -> Bool {
        loadAll().contains(conversationId)
    }

    func hide(conversationId: String) {
        var all = loadAll()
        all.insert(conversationId)
        defaults.set(Array(all), forKey: storageKey)
    }

    func unhide(conversationId: String) {
        var all = loadAll()
        all.remove(conversationId)
        defaults.set(Array(all), forKey: storageKey)
    }

    private func loadAll() -> Set<String> {
        Set(defaults.stringArray(forKey: storageKey) ?? [])
    }
}
