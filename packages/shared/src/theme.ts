/**
 * Unified BuildMart Design System Tokens
 * Single Source of Truth for Web (Tailwind/CSS) and Mobile (Flutter/Dart)
 * Standards: UI/UX Pro Max + Google Stitch Semantic Design Specification
 */

export interface ColorToken {
  hex: string;
  rgb: string;
  contrastOnLight: number; // Against #FFFFFF (minimum 4.5:1 for body text)
  contrastOnDark: number;  // Against #0B1527 (minimum 4.5:1 for body text)
  role: string;
}

export const brandColors = {
  // Primary Brand Identity (Industrial Deep Navy)
  primary: {
    DEFAULT: "#0B1527",
    light: "#172542",
    dark: "#060C17",
    surface: "#111E36",
  },
  // Accent & Action Identity (Construction Safety Amber / High Visibility)
  accent: {
    DEFAULT: "#F59E0B",
    hover: "#D97706",
    active: "#B45309",
    light: "#FEF3C7",
    muted: "#FBBF24",
  },
  // Industrial Steel Palette (Neutrals)
  steel: {
    50: "#F8FAFC",
    100: "#F1F5F9",
    200: "#E2E8F0",
    300: "#CBD5E1",
    400: "#94A3B8",
    500: "#64748B",
    600: "#475569",
    700: "#334155",
    800: "#1E293B",
    900: "#0F172A",
  },
  // Semantic System Feedback
  semantic: {
    success: "#10B981", // In-stock, Verified Delivery, Payment Captured
    warning: "#F59E0B", // Low inventory, Dispatch pending
    error: "#EF4444",   // Out of stock, Authorization rejected
    info: "#3B82F6",    // Spec sheet, GST calculation breakdown
  },
  // Background & Surface Tokens
  surface: {
    lightCanvas: "#F8FAFC",
    lightCard: "#FFFFFF",
    lightCardSubtle: "#F1F5F9",
    darkCanvas: "#060C17",
    darkCard: "#0B1527",
    darkCardSubtle: "#111E36",
  },
  // Border Tokens
  border: {
    lightSubtle: "#E2E8F0",
    lightStrong: "#CBD5E1",
    darkSubtle: "rgba(255, 255, 255, 0.08)",
    darkStrong: "rgba(255, 255, 255, 0.16)",
    focus: "#F59E0B",
  },
} as const;

export const typography = {
  fontFamilies: {
    heading: "Outfit, Rubik, sans-serif",
    body: "Inter, Nunito Sans, sans-serif",
    mono: "JetBrains Mono, monospace",
  },
  // Fluid Web Typography Scale (Desktop / Tablet / Responsive)
  webScale: {
    display: { fontSize: "clamp(2.5rem, 5vw, 4rem)", lineHeight: "1.1", fontWeight: "700", letterSpacing: "-0.02em" },
    h1: { fontSize: "clamp(2rem, 4vw, 3rem)", lineHeight: "1.2", fontWeight: "700", letterSpacing: "-0.015em" },
    h2: { fontSize: "clamp(1.5rem, 3vw, 2.25rem)", lineHeight: "1.25", fontWeight: "600", letterSpacing: "-0.01em" },
    h3: { fontSize: "clamp(1.25rem, 2vw, 1.75rem)", lineHeight: "1.3", fontWeight: "600" },
    bodyLg: { fontSize: "1.125rem", lineHeight: "1.6", fontWeight: "400" },
    body: { fontSize: "1rem", lineHeight: "1.5", fontWeight: "400" },
    bodySm: { fontSize: "0.875rem", lineHeight: "1.5", fontWeight: "400" },
    caption: { fontSize: "0.75rem", lineHeight: "1.4", fontWeight: "500" },
  },
  // Native Mobile Typography Scale (pt / dp, strictly calibrated for OLED density)
  mobileScale: {
    display: { fontSize: 32, lineHeight: 38, fontWeight: "700", letterSpacing: -0.5 },
    title1: { fontSize: 24, lineHeight: 30, fontWeight: "600", letterSpacing: -0.3 },
    title2: { fontSize: 20, lineHeight: 26, fontWeight: "600" },
    headline: { fontSize: 17, lineHeight: 22, fontWeight: "600" },
    bodyLg: { fontSize: 16, lineHeight: 22, fontWeight: "400" },
    body: { fontSize: 14, lineHeight: 20, fontWeight: "400" },
    caption: { fontSize: 12, lineHeight: 16, fontWeight: "500" },
    monoMetrics: { fontSize: 12, lineHeight: 16, fontWeight: "600" }, // Tabular pricing & weights
  },
} as const;

export const spacing = {
  scale: {
    xs: "4px",
    sm: "8px",
    md: "16px",
    lg: "24px",
    xl: "32px",
    "2xl": "48px",
    "3xl": "64px",
  },
  // Layout Gutters & Padding
  webContainerMax: "1440px",
  webGutter: "24px",
  mobileGutter: 16, // dp/pt
  mobileCardPadding: 16,
  touchTargetMinWeb: 44, // px
  touchTargetMinMobileAndroid: 48, // dp
  touchTargetMinMobileIos: 44, // pt
} as const;

export const elevation = {
  web: {
    card: "0 4px 20px -2px rgba(11, 21, 39, 0.08)",
    cardHover: "0 12px 30px -4px rgba(11, 21, 39, 0.14)",
    dropdown: "0 10px 38px -10px rgba(11, 21, 39, 0.25), 0 10px 20px -15px rgba(11, 21, 39, 0.15)",
    modal: "0 24px 60px -12px rgba(11, 21, 39, 0.35)",
  },
  mobile: {
    cardElevation: 2.0,
    modalElevation: 8.0,
    bottomBarElevation: 12.0,
  },
} as const;

export const breakpoints = {
  sm: "640px",
  md: "768px",
  lg: "1024px",
  xl: "1280px",
  "2xl": "1536px",
} as const;

export type BrandColors = typeof brandColors;
export type Typography = typeof typography;
export type Spacing = typeof spacing;
export type Elevation = typeof elevation;
export type Breakpoints = typeof breakpoints;
