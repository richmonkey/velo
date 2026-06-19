final class AppDI {
    static let shared = AppDI()

    private static let pushServerHost = "http://192.168.1.198:8080"

    let initializeXMTPClientUseCase: InitializeXMTPClientUseCase
    let syncAllConversationsUseCase: SyncAllConversationsUseCase
    let fetchConversationsUseCase: FetchConversationsUseCase
    let fetchConversationUseCase: FetchConversationUseCase
    let startConversationUseCase: StartConversationUseCase
    let deleteConversationUseCase: DeleteConversationUseCase
    let fetchMessagesUseCase: FetchMessagesUseCase
    let sendMessageUseCase: SendMessageUseCase
    let sendImageMessageUseCase: SendImageMessageUseCase
    let sendVoiceMessageUseCase: SendVoiceMessageUseCase
    let streamMessagesUseCase: StreamMessagesUseCase
    let streamAllMessagesUseCase: StreamAllMessagesUseCase
    let createGroupUseCase: CreateGroupUseCase
    let fetchGroupInfoUseCase: FetchGroupInfoUseCase
    let updateGroupAnnouncementUseCase: UpdateGroupAnnouncementUseCase
    let updateGroupNameUseCase: UpdateGroupNameUseCase
    let fetchGroupMembersUseCase: FetchGroupMembersUseCase
    let updateMyNicknameUseCase: UpdateMyNicknameUseCase
    let dissolveGroupUseCase: DissolveGroupUseCase
    let pushNotificationManager: PushNotificationManaging
    let setupPushNotificationsUseCase: SetupPushNotificationsUseCase
    let syncPushSubscriptionsUseCase: SyncPushSubscriptionsUseCase
    let setConversationMutedUseCase: SetConversationMutedUseCase
    let unreadCountRepository: UnreadCountRepositoryProtocol
    let conversationNoteRepository: ConversationNoteRepositoryProtocol
    let hiddenConversationStore: HiddenConversationStoring
    let mutedConversationStore: MutedConversationStoring
    let memberNicknameStore: MemberNicknameStoring
    var appPreferencesStore: AppPreferencesStoring
    let themeManager: ThemeManager

    private init() {
        let keychain = KeychainService()
        let clientManager = XMTPClientManager(keychain: keychain)

        let repository = XMTPRepository(clientManager: clientManager)
        initializeXMTPClientUseCase = DefaultInitializeXMTPClientUseCase(repository: repository)

        memberNicknameStore = MemberNicknameStore()
        conversationNoteRepository = ConversationNoteRepository()
        let conversationManager = XMTPConversationManager(clientManager: clientManager)
        let conversationRepository = ConversationRepository(conversationManager: conversationManager, memberNicknameStore: memberNicknameStore)
        syncAllConversationsUseCase = DefaultSyncAllConversationsUseCase(repository: conversationRepository)
        fetchConversationsUseCase = DefaultFetchConversationsUseCase(repository: conversationRepository)
        fetchConversationUseCase = DefaultFetchConversationUseCase(repository: conversationRepository)
        startConversationUseCase = DefaultStartConversationUseCase(repository: conversationRepository)
        deleteConversationUseCase = DefaultDeleteConversationUseCase(repository: conversationRepository)

        let chatRepository = ChatRepository(conversationManager: conversationManager)
        fetchMessagesUseCase = DefaultFetchMessagesUseCase(repository: chatRepository)
        sendMessageUseCase = DefaultSendMessageUseCase(repository: chatRepository)
        sendImageMessageUseCase = DefaultSendImageMessageUseCase(repository: chatRepository)
        sendVoiceMessageUseCase = DefaultSendVoiceMessageUseCase(repository: chatRepository)
        streamMessagesUseCase = DefaultStreamMessagesUseCase(repository: chatRepository)
        streamAllMessagesUseCase = DefaultStreamAllMessagesUseCase(repository: chatRepository)
        createGroupUseCase = DefaultCreateGroupUseCase(repository: conversationRepository)
        fetchGroupInfoUseCase = DefaultFetchGroupInfoUseCase(repository: conversationRepository)
        updateGroupAnnouncementUseCase = DefaultUpdateGroupAnnouncementUseCase(repository: conversationRepository)
        updateGroupNameUseCase = DefaultUpdateGroupNameUseCase(repository: conversationRepository)
        fetchGroupMembersUseCase = DefaultFetchGroupMembersUseCase(repository: conversationRepository)
        updateMyNicknameUseCase = DefaultUpdateMyNicknameUseCase(repository: conversationRepository)
        dissolveGroupUseCase = DefaultDissolveGroupUseCase(repository: conversationRepository)

        mutedConversationStore = MutedConversationStore()
        let pushManager = PushNotificationManager()
        pushManager.configure(pushServerHost: Self.pushServerHost)
        pushNotificationManager = pushManager
        let pushRepository = PushNotificationRepository(pushManager: pushManager, conversationManager: conversationManager, mutedConversationStore: mutedConversationStore)
        setupPushNotificationsUseCase = DefaultSetupPushNotificationsUseCase(repository: pushRepository)
        syncPushSubscriptionsUseCase = DefaultSyncPushSubscriptionsUseCase(repository: pushRepository)
        setConversationMutedUseCase = DefaultSetConversationMutedUseCase(repository: pushRepository)

        unreadCountRepository = UnreadCountRepository()
        hiddenConversationStore = HiddenConversationStore()

        let preferencesStore = AppPreferencesStore()
        appPreferencesStore = preferencesStore
        themeManager = ThemeManager(preferencesStore: preferencesStore)
    }

    @MainActor
    func makeLoadingViewModel() -> LoadingViewModel {
        LoadingViewModel(
            initializeXMTPClient: initializeXMTPClientUseCase,
            syncAllConversations: syncAllConversationsUseCase,
            preferencesStore: appPreferencesStore
        )
    }

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchConversations: fetchConversationsUseCase,
            fetchConversation: fetchConversationUseCase,
            setupPushNotifications: setupPushNotificationsUseCase,
            syncPushSubscriptions: syncPushSubscriptionsUseCase,
            streamAllMessages: streamAllMessagesUseCase,
            unreadCountStore: unreadCountRepository,
            noteRepository: conversationNoteRepository,
            memberNicknameStore: memberNicknameStore,
            deleteConversation: deleteConversationUseCase,
            hiddenConversationStore: hiddenConversationStore,
            mutedConversationStore: mutedConversationStore
        )
    }

    @MainActor
    func makeMeViewModel() -> MeViewModel {
        MeViewModel(initializeXMTPClient: initializeXMTPClientUseCase)
    }

    @MainActor
    func makeScanViewModel() -> ScanViewModel {
        ScanViewModel(startConversation: startConversationUseCase)
    }

    @MainActor
    func makeChatViewModel(conversationId: String, peerInboxId: String?, conversationTitle: String, kind: ConversationSummary.Kind) -> ChatViewModel {
        ChatViewModel(
            conversationId: conversationId,
            peerInboxId: peerInboxId,
            conversationTitle: conversationTitle,
            kind: kind,
            fetchMessages: fetchMessagesUseCase,
            sendMessage: sendMessageUseCase,
            sendImageMessage: sendImageMessageUseCase,
            sendVoiceMessage: sendVoiceMessageUseCase,
            streamMessages: streamMessagesUseCase,
            unreadCountStore: unreadCountRepository,
            noteRepository: conversationNoteRepository,
            fetchGroupMembers: fetchGroupMembersUseCase,
            fetchGroupInfo: fetchGroupInfoUseCase
        )
    }

    @MainActor
    func makeCreateGroupViewModel() -> CreateGroupViewModel {
        CreateGroupViewModel(
            fetchConversations: fetchConversationsUseCase,
            noteRepository: conversationNoteRepository,
            createGroup: createGroupUseCase
        )
    }

    @MainActor
    func makeConversationSettingsViewModel(conversationId: String, peerInboxId: String?) -> ConversationSettingsViewModel {
        ConversationSettingsViewModel(
            conversationId: conversationId,
            peerInboxId: peerInboxId,
            noteRepository: conversationNoteRepository,
            mutedConversationStore: mutedConversationStore,
            setConversationMuted: setConversationMutedUseCase
        )
    }

    @MainActor
    func makeGroupSettingsViewModel(conversationId: String) -> GroupSettingsViewModel {
        GroupSettingsViewModel(
            conversationId: conversationId,
            fetchGroupInfo: fetchGroupInfoUseCase,
            fetchGroupMembers: fetchGroupMembersUseCase,
            noteRepository: conversationNoteRepository,
            dissolveGroup: dissolveGroupUseCase,
            mutedConversationStore: mutedConversationStore,
            setConversationMuted: setConversationMutedUseCase
        )
    }

    @MainActor
    func makeGroupAnnouncementEditViewModel(conversationId: String) -> GroupAnnouncementEditViewModel {
        GroupAnnouncementEditViewModel(
            conversationId: conversationId,
            fetchGroupInfo: fetchGroupInfoUseCase,
            updateGroupAnnouncement: updateGroupAnnouncementUseCase
        )
    }

    @MainActor
    func makeMyNicknameEditViewModel(conversationId: String) -> MyNicknameEditViewModel {
        MyNicknameEditViewModel(
            conversationId: conversationId,
            fetchGroupMembers: fetchGroupMembersUseCase,
            updateMyNickname: updateMyNicknameUseCase
        )
    }

    @MainActor
    func makeGroupNameEditViewModel(conversationId: String) -> GroupNameEditViewModel {
        GroupNameEditViewModel(
            conversationId: conversationId,
            fetchGroupInfo: fetchGroupInfoUseCase,
            updateGroupName: updateGroupNameUseCase
        )
    }

    @MainActor
    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(preferencesStore: appPreferencesStore)
    }

    @MainActor
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(preferencesStore: appPreferencesStore)
    }
}
