struct GroupMember: Identifiable, Hashable {
    let id: String
    let isMe: Bool
    let nickname: String?
}
