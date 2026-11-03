# Accessibility Statement for BuildMart

BuildMart is committed to ensuring digital accessibility for people with disabilities. We are continually improving the user experience for everyone and applying the relevant accessibility standards across our mobile application (Flutter), web portal (Next.js), and backend administration interfaces.

---

## 1. Conformance Status

We aim to adhere to the **Web Content Accessibility Guidelines (WCAG) 2.1 Level AA** standards. These guidelines explain how to make web and mobile content more accessible to people with disabilities, and user-friendly for everyone.

### Supported Standards & Frameworks
- **WCAG 2.1 AA** guidelines across Web and Mobile
- **Section 508** of the U.S. Rehabilitation Act
- **Material Design Accessibility Guidelines** for Flutter Android & iOS
- **WAI-ARIA 1.2** Authoring Practices for React / Next.js web applications

---

## 2. Key Accessibility Features

### Mobile Application (Flutter)
- **Minimum Touch Targets**: All interactive buttons, icon buttons, list items, and input fields maintain a minimum touch target size of 48×48 dp to accommodate motor impairments.
- **Dynamic Text Scaling**: Full support for system-level font scaling up to 200% without truncation, layout distortion, or overlapping elements.
- **Screen Reader Compatibility**: Built using Flutter `Semantics` widgets with descriptive labels, hints, and state information for Android TalkBack and iOS VoiceOver.
- **High-Contrast Dark Mode**: True OLED dark theme (`#121212` / `#1E1E1E`) with WCAG-compliant contrast ratios (greater than 4.5:1 for body copy and 3:1 for UI components).
- **Reduced Motion Support**: Respects system "Remove animations" and "Reduce motion" settings to prevent motion-triggered vestibular symptoms.
- **Haptic & Visual Feedback**: All critical actions (e.g., checkout, order confirmation, cart updates) provide dual feedback (haptic vibration and visual toasts/dialogs).

### Web Application (Next.js)
- **Semantic HTML & ARIA**: Use of landmark elements (`<header>`, `<nav>`, `<main>`, `<section>`, `<footer>`) and ARIA attributes (`aria-expanded`, `aria-label`, `aria-live`) for dynamic content.
- **Full Keyboard Navigation**: All features are operable using keyboard navigation alone (`Tab`, `Shift+Tab`, `Enter`, `Space`, `Escape`, arrow keys) with distinct, high-visibility focus indicators.
- **Color Contrast**: All text and active interactive components maintain a minimum contrast ratio of 4.5:1 against their backgrounds.
- **Form Accessibility**: Explicit `<label>` associations for every form input, real-time error descriptions linked via `aria-describedby`, and clear validation messages.

---

## 3. Supported Environments & Assistive Technologies

BuildMart is tested and designed to be compatible with:
- **Screen Readers**:
  - TalkBack on Android 10+
  - VoiceOver on iOS 15+
  - NVDA and JAWS on Windows (Chrome, Firefox, Edge)
  - VoiceOver on macOS (Safari, Chrome)
- **Input Methods**:
  - Physical keyboards and switch access devices
  - Touchscreen gestures and assistive touch overlays
  - Voice control and speech recognition input

---

## 4. Known Limitations & Roadmap

While we strive for comprehensive accessibility, we are actively working on the following improvements:
- **Map & Geolocation Interfaces**: Enhancing audio descriptions and non-visual alternatives for interactive map-based live order tracking.
- **PDF Invoices & Receipts**: Automating PDF tagging and structured headers for screen-reader-optimized invoice downloads.
- **Third-Party Payment Gateways**: Continuously auditing external payment sheets (UPI, Razorpay, Stripe) to ensure seamless assistive transitions.

---

## 5. Feedback & Reporting Barriers

We welcome your feedback on the accessibility of BuildMart. If you encounter accessibility barriers, or need content in an alternative format, please let us know:

- **GitHub Issues**: Open an issue labeled `accessibility` via [GitHub Issues](https://github.com/KatkamKoushik/BuildMart/issues) using our issue template.
- **Email**: Send accessibility feedback or barrier reports to `support@buildmart.app` or open a discussion on GitHub.
- **Response Time**: We aim to review and acknowledge accessibility feedback within 2 business days.

---

## 6. Technical Specifications

Accessibility of BuildMart relies on the following technologies to work with the particular combination of web browser and any assistive technologies or plugins installed on your device:
- HTML5 / WAI-ARIA
- CSS3 / Tailwind CSS
- JavaScript / TypeScript / React / Next.js
- Dart / Flutter Framework

These technologies are relied upon for conformance with the accessibility standards used.
