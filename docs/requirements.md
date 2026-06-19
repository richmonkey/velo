# VeloChat Requirements

> Derived from the current implementation (Presentation / Domain / Data / Infrastructure layers). Reflects existing functionality, not future plans.

## 1. Overview

VeloChat is an iOS instant messaging app built on [XMTP](https://xmtp.org) (a decentralized messaging protocol where a wallet address serves as identity), using SwiftUI + Clean Architecture (Presentation/Domain/Data/Infrastructure layering).

## 2. Launch & Identity Initialization

- On launch, the app shows a loading screen (LoadingView) and initializes the XMTP client (InitializeXMTPClientUseCase).
- On success, an `XMTPIdentity` (inboxId + walletAddress) is obtained and the user is taken to the conversation list (HomeView).
- On failure, an error message is displayed.

## 3. Conversation List (Home)

- Lists conversations (groups + DMs), sorted by recent activity, showing the last message preview and an unread-count badge.
- Supports pull-to-refresh and auto-refreshing unread counts on appear.
- Has dedicated UI for empty, loading, and error states (with retry).
- Top toolbar:
  - Left: entry point into the "Me" screen.
  - Right "+" menu: scan to add a contact / create a group.
- Tapping a conversation opens the chat screen.

## 4. Me (Identity & Sharing)

- Displays the current user's XMTP inboxId and its corresponding QR code (for others to scan and add you).
- Supports sharing the QR code image via the system share sheet.
- Provides an entry point to the scan screen (add contact).

## 5. Scan / Add Contact

- Scans a QR code using the device camera (QRScannerViewController).
- On a successful scan, starts a conversation with the peer's inboxId (StartConversationUseCase); shows a loading state while creating and an error message on failure.
- On success, automatically dismisses and refreshes the conversation list.

## 6. Create Group

- Step 1: multi-select members from the existing contacts list (derived from existing conversations).
- Step 2: enter a group name, then confirm to create the group (CreateGroupUseCase).
- On success, returns to the home screen and refreshes the conversation list.

## 7. Chat (DM / Group)

### 7.1 Sending & Receiving Messages
- Send text messages (SendMessageUseCase).
- Send image messages: pick from photo library or capture with camera, then compress before sending (SendImageMessageUseCase, ImageCompressor).
- Send voice messages: tap to record with auto-stop logic, then send (SendVoiceMessageUseCase, AudioRecorder); includes playback, duration display, and proximity-based audio routing (ProximityAudioRouter, earpiece/speaker switching).
- Paginated history loading for the message list (FetchMessagesUseCase + loadMore, triggered by pull-to-refresh).
- Real-time message streaming (StreamMessagesUseCase / StreamAllMessagesUseCase); auto-scrolls to the bottom when new messages arrive.

### 7.2 Message Display
- Distinct bubble styles and alignment for "me" vs. the other party.
- In group chats, shows the sender's nickname for messages not from "me" (resolved via group nickname lookup).
- System notice messages (e.g., nickname changes) are shown as centered pill-style hints, supporting an `{{actor}}` placeholder substituted with the actor's name.
- Image messages support full-screen viewing on tap; the full-screen viewer supports pinch-to-zoom, drag-to-pan, double-tap to zoom in/reset, and single-tap to dismiss.
- Voice messages support play/pause and show duration.

### 7.3 Conversation Title & Settings Entry
- DM: navigates to "Conversation Settings", where a contact note can be edited (persisted via ConversationNoteRepository).
- Group: navigates to "Group Settings", showing and allowing edits to the group name, group announcement, and my group nickname, plus a member list (with a "me" indicator).

## 8. Group Settings

- View and edit the group name (UpdateGroupNameUseCase).
- View and edit the group announcement (UpdateGroupAnnouncementUseCase); shows "Not set" when empty.
- View and edit my group nickname (UpdateMyNicknameUseCase + MemberNicknameStore local cache).
- View the group member list (FetchGroupMembersUseCase), with nickname resolution for display.
- Failures are surfaced uniformly via an alert dialog with the error message.

## 9. Push Notifications

- Requests notification permission and registers for push (SetupPushNotificationsUseCase).
- Syncs push subscriptions against the current conversation list (SyncPushSubscriptionsUseCase), ensuring only relevant conversations receive remote notifications.
- Handling of incoming background pushes is owned by PushNotificationManager / AppDelegate.

## 10. Unread Messages

- Tracks and displays unread counts per conversation (UnreadCountRepository); the list badge refreshes in real time.

## 11. Identity & Key Management

- Wallet/client keys are stored securely via KeychainService.
- Local state such as contact notes, group member nicknames, and unread counts is persisted through their respective repositories (see the Infrastructure layer for storage details).

## 12. Non-Functional Notes

- All network/protocol interaction is encapsulated behind XMTPRepository / XMTPClientManager / XMTPConversationManager; the UI layer never calls the XMTP SDK directly.
- Dependency injection is centralized through `AppDI.shared`, which constructs ViewModels with UseCases/Repositories injected via initializers.
- Project files are managed via XcodeGen (`Project.yml`); the `.pbxproj` file is never edited by hand.
