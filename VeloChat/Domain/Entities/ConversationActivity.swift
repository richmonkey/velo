struct ConversationActivity {
    struct NicknameUpdate {
        let inboxId: String
        let nickname: String
    }

    let conversationId: String
    let isFromMe: Bool
    let nicknameUpdate: NicknameUpdate?
}
