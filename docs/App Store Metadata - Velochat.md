# App Store Metadata - Velochat

All fields below use plain ASCII punctuation only (no Unicode dashes, box-drawing characters, or smart quotes), as required for App Store Connect submission.

## App Name (Max 30 characters)

```
Velochat
```

(8 characters)

## Subtitle (Max 30 characters)

```
Private Decentralized Chat
```

(26 characters)

## Keywords (Max 100 characters total, comma-separated)

```
chat,messenger,privacy,encrypted,decentralized,xmtp,web3,secure,messaging,crypto,anonymous,private
```

(98 characters)

## Promotional Text (Max 170 characters)

```
Velochat is private messaging with no accounts and no servers. Built on the XMTP protocol, every chat is end-to-end encrypted. Scan a QR code to start chatting instantly.
```

(170 characters)

## Description (Max 4000 characters)

```
Velochat is a decentralized messaging app built on the XMTP protocol. There are no accounts, no usernames, and no passwords. Your identity is a cryptographic inbox ID generated automatically on your device the first time you open the app.

PRIVATE BY DESIGN
Every message - text, photo, and voice - is end-to-end encrypted using the XMTP network's security protocol. Messages are never stored on a central server that Velochat controls. Your conversations stay between you and the people you talk to.

NO SIGN-UP REQUIRED
Skip the registration forms. Velochat creates your decentralized identity automatically and stores your keys securely in your device's Keychain. There is nothing to remember and nothing to lose if you switch devices with the same wallet.

SIMPLE WAYS TO CONNECT
- Share your personal QR code or scan a friend's to start a direct conversation instantly.
- Create group chats with multiple contacts, set a group name and announcement, and give yourself a custom nickname per group.
- See exactly who sent what in group chats with clear sender labels.

RICH MESSAGING
- Send text messages in real time with live delivery.
- Share photos from your library or capture them with the camera, automatically compressed before sending.
- Record and send voice messages with one tap; playback automatically switches between the earpiece and speaker based on how you hold your phone.
- Tap any photo to view it full-screen with pinch-to-zoom and pan.

STAY ON TOP OF YOUR CONVERSATIONS
Unread counts, last-message previews, and push notifications keep you up to date without needing to keep the app open. Pull to refresh your conversation list or message history at any time.

LIGHT AND DARK MODE
Choose System, Light, or Dark appearance from Settings. Velochat adapts immediately, no restart required.

NO ADS, NO TRACKING
Velochat does not show ads and does not track your activity for advertising purposes. The app only requests camera access to scan QR codes and microphone access to record voice messages.

Velochat is built for people who want a fast, modern chat experience without giving up control of their identity or their conversations.
```

(2158 characters)

## Category

- Primary: Utilities (`public.app-category.utilities`, matches `LSApplicationCategoryType` in `Project.yml`)

## Notes for App Review

```
APP OVERVIEW
Velochat is a decentralized messaging app built on the XMTP protocol (https://xmtp.org). This is version 1.0, build 1.

ACCOUNTS AND IDENTITY
Velochat does not use traditional accounts, email, or passwords. On first launch, the app automatically generates a decentralized identity (an XMTP inbox ID and wallet address) and stores the associated keys in the iOS Keychain. There is no login screen to test; identity creation happens automatically during the launch/loading screen.

HOW TO TEST CORE FEATURES
1. Launch the app. It will initialize automatically and land on an empty Chats list (no login required).
2. Tap the person icon (top left) to view your own QR code under "Me".
3. To test messaging between two accounts, install the app on a second device or simulator, open "Me" on one device, and use "Scan QR Code" on the other device's Chats screen (+ menu > Add Contact) to scan it. This creates a direct conversation between the two identities.
4. From the same + menu, "Create Group" lets you select existing contacts and create a group chat.
5. Inside a conversation you can send text, photos (camera or library), and voice messages (tap the microphone icon to record, tap Done to send).
6. Settings (gear icon from "Me") lets you switch appearance (System/Light/Dark), replay the welcome guide, view usage instructions, share the app, and rate the app.

PRIVACY
The app requests Camera access (to scan QR codes for adding contacts) and Microphone access (to record voice messages) only. No advertising identifiers, analytics, or third-party tracking SDKs are used. Privacy Policy and Terms of Service are linked from Settings and open in the system browser.

PRODUCT HIGHLIGHTS
- No account registration; identity is created automatically and locally.
- End-to-end encrypted text, photo, and voice messaging via the XMTP protocol.
- QR-code based contact discovery; no phone number or email required.
- Group chats with editable name, announcement, and per-group nicknames.
- Light, Dark, and System appearance modes.

THIRD-PARTY / EXTERNAL CONTENT
The app uses the open-source XMTP iOS SDK (https://github.com/xmtp/xmtp-ios) for protocol connectivity. No other third-party copyrighted media, fonts, or content is bundled with the app. All icons are system SF Symbols provided by iOS.

CHILDREN
Velochat is not directed at children and is not designed, marketed, or intended for use by children under 13. There is no age-gating because the app collects no personal information at all (no name, email, or phone number).
```

## Copyright

```
© 2026 Daibou007 Team. All rights reserved.
```
