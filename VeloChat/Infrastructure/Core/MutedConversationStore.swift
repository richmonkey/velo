import Foundation

final class MutedConversationStore: MutedConversationStoring {
    private let defaults = UserDefaults.standard
    private let storageKey = "velo.muted_conversation_ids"

    func isMuted(conversationId: String) -> Bool {
        loadAll().contains(conversationId)
    }

    func mute(conversationId: String) {
        var all = loadAll()
        all.insert(conversationId)
        defaults.set(Array(all), forKey: storageKey)
    }

    func unmute(conversationId: String) {
        var all = loadAll()
        all.remove(conversationId)
        defaults.set(Array(all), forKey: storageKey)
    }

    private func loadAll() -> Set<String> {
        Set(defaults.stringArray(forKey: storageKey) ?? [])
    }
}
