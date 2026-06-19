# VeloChat Full App Page List \& Functional Specification

## 1\. Document Introduction

This document defines the complete page structure, mandatory system pages, business functional pages, and detailed page\-level functional rules for the VeloChat iOS client\. It covers startup flow, user guide flow, core chat business flow, and system configuration auxiliary pages\. All specifications adapt to the US App Store release version, follow one\-time purchase, no\-login, English\-only product rules, and support light/dark mode adaptation\.

All page logic matches the actual running functions of the app, covering mandatory custom pages required for shelf launch and inherent business module pages, forming a complete closed\-loop page system\.

## 2\. Global Page General Rules

- All pages support iOS native light/dark mode automatic adaptation\.

- All page text, buttons, prompts, and popups are English\-only, no other languages\.

- All pages follow unified UI design system \(color, font, icon, gradient specification\)\.

- All empty/loading/error network abnormal states have unified UI adaptation and retry logic\.

- No manual account login, all identity initialization is automatically completed by the XMTP decentralized protocol\.

## 3\. Mandatory Public System Pages \(Shelf Launch Required\)

### 3\.1 App Icon \(System Level\)

**Page Attribute**: System desktop entrance, no independent page stack

**Core Functional Specification**

- Unified tech minimalist style icon, matching app visual positioning\.

- Support dynamic adaptation of iOS dark/light desktop background\.

- Click the icon to trigger app cold start and jump to the launch loading page\.

- Comply with US App Store icon size, resolution and visual review specifications\.

### 3\.2 Launch Loading Page

**Page Route**: App cold start first page

**Core Functional Specification**

- Display app loading animation and network initialization prompt text\.

- Automatically execute XMTP client initialization and decentralized identity generation logic\.

- Success: automatically jump to welcome guide page \(first launch\) / home conversation list \(non\-first launch\)\.

- Failure: display network error prompt and retry button, support manual re\-initialization\.

### 3\.3 Welcome \& Onboarding Guide Page \(First Launch Only\)

**Page Route**: Triggered only on the first app launch after successful network initialization

**Core Functional Specification**

- Multi\-page sliding guide, display core app positioning and core functions: decentralized anonymous chat, QR code contact adding, group chat, multimedia message support\.

- Use concise English copy and minimalist tech illustrations, no redundant introduction\.

- Support left/right sliding switching guide pages\.

- The last guide page provides a “Start Using” button to enter the in\-app usage mask guide page\.

- Only pop up for the first launch, no repeated display after skipping/confirming\.

### 3\.4 In\-App Usage Mask Guide Page

**Page Route**: After completing the welcome guide for the first time, overlay display on the home page

**Core Functional Specification**

- Transparent mask highlighting key operation entrances: home add button, personal center entrance, conversation list core functions\.

- Display short English operation hints for each core function area\.

- Support single\-click mask to close step by step or one\-click close all guides\.

- Local cache marks the completion of the guide, no repeated pop\-ups in subsequent use\.

### 3\.5 App Usage Instruction Page

**Page Route**: Settings \- Usage Instructions

**Core Functional Specification**

- Hierarchical display of complete app usage rules: decentralized identity explanation, contact adding method, group chat creation, message sending rules, push notification settings, privacy and security instructions\.

- Support page sliding scrolling, adaptive text layout\.

- All content is standardized English description, accurate and concise, in line with US user reading habits\.

- No login/account related description, highlight no\-registration decentralized features\.

### 3\.6 Settings Page

**Page Route**: Home \- Personal Center \- Settings

**Core Functional Specification**

- Integrate all system configuration entries: dark/light mode switching, push notification settings, usage instructions, about app, share app, App Store rating, privacy settings\.

- Support manual switching of system theme \(follow system/light mode/dark mode\)\.

- Support push notification permission viewing and quick jump to system settings\.

- Unified cell style, clear module division, and responsive abnormal state processing\.

### 3\.7 About Page

**Page Route**: Settings \- About VeloChat

**Core Functional Specification**

- Display app icon, app name, version number, build number information\.

- Display core product introduction: XMTP decentralized messaging, privacy security features\.

- Provide privacy policy and terms of service entry \(web view internal opening\)\.

- Display official decentralized network related brief introduction\.

### 3\.8 App Share Page

**Page Route**: Settings \- Share This App

**Core Functional Specification**

- Call iOS system native share sheet\.

- Support sharing App Store download link, app introduction copy, and app icon image\.

- Adapt to all iOS sharing channels: AirDrop, Messages, Mail, social platforms, etc\.

- Shared copy is standardized English, highlighting one\-time purchase, no\-account, decentralized chat features\.

### 3\.9 App Store Rating Page

**Page Route**: Settings \- Rate Us

**Core Functional Specification**

- Click the entry to directly jump to the official VeloChat App Store rating page\.

- Comply with Apple’s official rating pop\-up rules, no forced rating pop\-up\.

- Support user voluntary scoring and comment operation\.

## 4\. Core Business Functional Pages

### 4\.1 One\-Time Purchase Unlock Page

**Page Route**: Automatically pop up after first launch network initialization

**Core Functional Specification**

- Display one\-time lifetime purchase rules and full feature list\.

- Provide “Purchase Now” and “Restore Purchase” buttons\.

- Connect Apple official IAP payment interface, support receipt verification\.

- After successful purchase/restore, permanently unlock all core functions and no longer pop up\.

### 4\.2 Home Conversation List Page

**Page Route**: App main home page

**Core Functional Specification**

- Display all DM and group conversations, sorted by recent activity\.

- Each conversation displays last message preview, time stamp, and unread count badge\.

- Support pull\-to\-refresh and automatic refresh of unread counts on page appearance\.

- Adapt empty/loading/error states with retry function\.

- Top left: personal center entrance; top right: add contact / create group menu entrance\.

- Tap conversation item to jump to chat detail page\.

### 4\.3 My Identity Page

**Page Route**: Home \- Top Left Avatar/Identity Entry

**Core Functional Specification**

- Display user’s unique XMTP inbox ID and wallet address\.

- Generate real\-time exclusive identity QR code for contact scanning and adding\.

- Support QR code image and identity information sharing\.

- Provide quick entry to scan and add contacts\.

### 4\.4 QR Scan \& Add Contact Page

**Page Route**: Home Add Menu / My Identity Page

**Core Functional Specification**

- Apply for camera permission, real\-time camera preview scanning\.

- Automatically identify valid XMTP QR codes\.

- Automatically create DM conversation after successful scanning, display loading state\.

- Automatically refresh home conversation list after creation success\.

- Error prompt for invalid QR code and abnormal scanning\.

### 4\.5 Create Group Page

**Page Route**: Home \- Top Right Add Menu \- Create Group

**Core Functional Specification**

- Step 1: Multi\-select members from existing conversation contacts\.

- Step 2: Custom input group name, support creation confirmation\.

- Execute group creation logic, display loading state\.

- Automatically return to home page and refresh list after successful creation\.

### 4\.6 Chat Detail Page \(DM / Group Unified\)

**Page Route**: Tap any conversation on home page

**Core Functional Specification**

- Support real\-time sending and receiving of text, image, and voice messages\.

- Image messages support shooting/album selection, automatic compression and sending, full\-screen preview and zoom\.

- Voice messages support recording, auto\-stop, playback, and proximity sensor audio switching\.

- Support message history pagination loading and pull\-to\-refresh for historical records\.

- Real\-time message streaming, auto\-scroll to bottom for new messages\.

- Distributed bubble styles for self/other\-party messages, group chat sender nickname display\.

- Top navigation bar provides entry to conversation/group settings\.

### 4\.7 DM Conversation Settings Page

**Page Route**: DM Chat Page \- Top Right Settings

**Core Functional Specification**

- Support custom editing and saving of contact notes\.

- Local persistent storage of note content, no data loss after app restart\.

- Real\-time display of saved note content when entering the page\.

### 4\.8 Group Settings Page

**Page Route**: Group Chat Page \- Top Right Settings

**Core Functional Specification**

- Support editing group name, group announcement, and personal group nickname\.

- Display complete group member list, resolve and show member nicknames\.

- Mark current user with “Me” identifier in member list\.

- Unified error alert prompt for all modification failures\.

## 5\. Page Full Inventory Summary

The VeloChat app page system fully covers all mandatory shelf launch pages and business functional pages, including: system icon, launch page, welcome guide page, in\-app mask guide page, usage instruction page, settings page, about page, app share page, App Store rating page, and all core chat business pages\. All pages follow unified UI and interactive specifications, meeting US App Store review standards and one\-time purchase no\-login product positioning\.

> （注：部分内容可能由 AI 生成）
