# VeloChat UI Design System \& Visual Specification Document

## 1\. Design Overview \& Global Style Positioning

### 1\.1 Core Design Style

VeloChat adopts a**Minimalist Futuristic Tech Style** tailored for decentralized Web3 instant messaging scenarios\. The overall visual is clean, lightweight, and high\-tech, abandoning redundant decorative elements\. It focuses on digital sense, privacy security, and efficient information transmission, matching the core attributes of XMTP decentralized, open, and secure communication\.

Artistic positioning: Low\-saturation, high\-contrast, minimalist digital aesthetics; smooth layered vision, subtle dynamic gradients, and frosted glass texture to highlight the sense of technological precision and user privacy\.

### 1\.2 Design Principles

- **Consistency**: Unified color logic, font specification, icon style and component layering in light/dark mode\.

- **Readability**: Priority to text and message readability, reasonable contrast ratio, adaptive font hierarchy\.

- **Tech Sense**: Subtle gradient, shadow layering, and translucent texture to reflect decentralized network characteristics\.

- **Accessibility**: Comply with Apple iOS Human Interface Guidelines and US App Store visual accessibility standards\.

## 2\. Global Color System \(Light \& Dark Mode\)

All color values adopt hex standard codes, supporting iOS native light/dark mode automatic switching\. The color system includes Base Color, Primary Accent Color, Secondary Auxiliary Color, Text Color, Background Color, Border \& Shadow Color, and Gradient Color\.

### 2\.1 Base Brand Color \(Core Tone\)

The base color inherits the calm, secure technological tone of decentralized protocols, taking deep blue as the core brand tone to interpret security, trust and digital connectivity\.

- **Brand Base Color**: \#165DFF \(Standard Tech Blue\)

- Color Attribute: Low saturation, high stability, suitable for long\-term UI display, no visual fatigue, highlighting network security attributes\.

### 2\.2 Key Accent Color \(Focus \& Interactive\)

Used for core interactive elements, functional highlights, button emphasis, new message prompts, and status identification\.

- **Primary Accent Color**: \#00C4FF \(Cyan Tech Highlight\)

- **Warning \& Unread Accent**: \#FF4D4F \(Standard Red, for unread badge, error prompt\)

- **Success Accent**: \#00B42A \(Standard Green, for message sent success, operation completion\)

### 2\.3 Light Mode Full Color Specification

#### 2\.3\.1 Background Colors

- Global Background: \#F7F8FA \(Ultra\-light gray, soft eye protection\)

- Card/Cell Background: \#FFFFFF \(Pure white, prominent layering\)

- Chat Bubble Self: \#165DFF \(Brand blue\)

- Chat Bubble Other: \#F2F3F5 \(Light gray neutral\)

- System Message Background: \#E8EBF0 \(Faint gray pill background\)

#### 2\.3\.2 Text Colors

- Primary Text \(Title/Main Content\): \#1D2129 \(Deep black, high readability\)

- Secondary Text \(Subtitle/Description\): \#4E5969 \(Medium gray\)

- Tertiary Text \(Hint/Placeholder\): \#86909C \(Light gray\)

- Inverse Text \(On Accent/Blue Background\): \#FFFFFF \(Pure white\)

#### 2\.3\.3 Border \& Divider Colors

- Normal Border: \#E5E6EB

- Divider Line: \#F2F3F5

### 2\.4 Dark Mode Full Color Specification

#### 2\.4\.1 Background Colors

- Global Background: \#0A0E17 \(Deep dark tech background\)

- Card/Cell Background: \#151A26 \(Dark gray card layering\)

- Chat Bubble Self: \#2371FF \(Brightened brand blue, adaptive dark mode\)

- Chat Bubble Other: \#2A3143 \(Dark neutral gray\)

- System Message Background: \#333A48 \(Dark pill background\)

#### 2\.4\.2 Text Colors

- Primary Text \(Title/Main Content\): \#F2F3F5 \(Off\-white\)

- Secondary Text \(Subtitle/Description\): \#C9CDD4 \(Light gray\)

- Tertiary Text \(Hint/Placeholder\): \#86909C \(Medium gray\)

- Inverse Text \(On Accent Background\): \#FFFFFF \(Pure white\)

#### 2\.4\.3 Border \& Divider Colors

- Normal Border: \#2A3143

- Divider Line: \#1F2532

## 3\. Gradient Color Specification \(Global Universal\)

Gradients are only used for core buttons, brand entries, and special highlight components, avoiding overuse to ensure minimalist tech style consistency\. All gradients support light/dark mode adaptive brightness adjustment\.

### 3\.1 Primary Brand Gradient

- Gradient Direction: Left to Right

- Start Color: \#165DFF

- End Color: \#00C4FF

- Applicable Scenarios: Primary action buttons, purchase unlock buttons, page brand headers

### 3\.2 Dark Mode Adaptive Gradient

- Gradient Direction: Left to Right

- Start Color: \#2371FF

- End Color: \#00D8FF

- Feature: Higher brightness and transparency to adapt dark background, enhance tech layering

### 3\.3 Translucent Frosted Gradient

- Applicable Scenarios: Navigation bar, bottom input bar, popup card background

- Light Mode: White translucent gradient \(rgba\(255,255,255,0\.85\) to rgba\(247,248,250,0\.9\)\)

- Dark Mode: Dark translucent gradient \(rgba\(10,14,23,0\.85\) to rgba\(21,26,38,0\.9\)\)

- Matching Effect: iOS frosted glass blur \(Blur 20pt\) \+ gradient overlay

## 4\. Icon Style \& Color Specification

### 4\.1 Global Icon Style

Unified **Minimalist Linear Tech Icon Style**, consistent with app overall positioning\.

- Stroke Specification: Uniform 1\.5pt stroke width, no thick and thin variation

- Corner Style: 2pt rounded corner, no sharp right angle, soft tech sense

- Outline Rule: Pure linear main body, partial functional icons adopt subtle fill

- Proportion: 1:1 square uniform grid, unified visual weight

- Style Taboo: No cartoon texture, no complex gradient overlay, no exaggerated three\-dimensional effect

### 4\.2 Icon Color Specification

#### 4\.2\.1 Light Mode Icon Color

- Default Icon \(Ordinary Function\): \#4E5969 \(Secondary text gray\)

- Active/Selected Icon: \#165DFF \(Brand base color\)

- Highlight Functional Icon \(Scan/Add\): \#00C4FF \(Accent color\)

- Status Icon \(Success/Error\): Follow global success/warning color system

#### 4\.2\.2 Dark Mode Icon Color

- Default Icon \(Ordinary Function\): \#C9CDD4 \(Light gray\)

- Active/Selected Icon: \#2371FF \(Dark mode adaptive brand color\)

- Highlight Functional Icon \(Scan/Add\): \#00D8FF \(Adaptive accent color\)

### 4\.3 Universal Icon List Specification

Home, Mine, Scan, Add Group, Settings, Voice, Image, Send and other core icons all follow the above linear unified specification to ensure global visual consistency\.

## 5\. Font System Specification \(iOS Unified\)

Adopt iOS native **SF Pro Text / SF Pro Display** font system, no custom third\-party fonts, compliant with Apple review rules\. Establish 6\-level font hierarchy, applicable to all pages of the app\.

### 5\.1 Universal Font Rule

- English Font: SF Pro Text / SF Pro Display

- Font Weight Rule: Title uses Medium/Semibold; body text uses Regular; hint text uses Light

- Line Height: Unified 1\.2 times font size line height for all levels

### 5\.2 Font Size \& Color Hierarchy \(Light \& Dark Mode\)

#### Level 1: Large Page Title

- Font Size: 24pt

- Weight: Semibold

- Light Mode Color: \#1D2129

- Dark Mode Color: \#F2F3F5

- Scenario: Page top main title, brand header

#### Level 2: Secondary Title / Module Title

- Font Size: 20pt

- Weight: Medium

- Light Mode Color: \#1D2129

- Dark Mode Color: \#F2F3F5

- Scenario: Group settings title, list module title

#### Level 3: Functional Title / List Main Text

- Font Size: 17pt \(iOS standard body size\)

- Weight: Regular

- Light Mode Color: \#1D2129

- Dark Mode Color: \#F2F3F5

- Scenario: Conversation list name, button text, setting item text

#### Level 4: Message Preview / Sub Description

- Font Size: 15pt

- Weight: Regular

- Light Mode Color: \#4E5969

- Dark Mode Color: \#C9CDD4

- Scenario: Chat list message preview, function description text

#### Level 5: Hint / Placeholder / Time Text

- Font Size: 13pt

- Weight: Light

- Light Mode Color: \#86909C

- Dark Mode Color: \#86909C

- Scenario: Time stamp, placeholder text, empty state hint

#### Level 6: Mini Tag Text

- Font Size: 11pt

- Weight: Light

- Light Mode Color: \#86909C

- Dark Mode Color: \#86909C

- Scenario: Unread count tag, system small prompt

## 6\. Overall UI Visual Style Summary

### 6\.1 Core Style Feature

VeloChat takes **lightweight futuristic tech minimalism** as the core, abandons redundant decoration, and uses blue\-cyan gradient tech tone \+ frosted translucent layering to shape the visual perception of "decentralized security, efficient communication"\. The overall vision is highly consistent with Web3 decentralized product attributes, conforming to US user’s minimalist aesthetic preference\.

### 6\.2 Light Mode Overall Tone

Soft light background \+ high\-precision blue brand color, clean and refreshing, strong readability, suitable for daily long\-term use, with a sense of precise digital technology\.

### 6\.3 Dark Mode Overall Tone

Deep dark background \+ bright blue\-cyan adaptive highlight, low light interference, prominent message content, strong futuristic cyber tech sense, meeting the night use scenario and high\-end visual positioning\.

## 7\. Adaptation \& Compatibility Rules

- All color gradients, fonts, and icon styles are adapted to iOS 15\+ and all iPhone screen sizes\.

- Light/dark mode follows iOS system automatic switching, supporting manual forced switching inside the app \(optional expansion\)\.

- All color contrast ratios meet WCAG 2\.1 accessibility standards, complying with US App Store visual accessibility review requirements\.

- No overly fancy dynamic effects, ensuring app running fluency and avoiding Apple review risk of excessive animation\.

> （注：部分内容可能由 AI 生成）
