import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        buildmart: {
          navy: {
            DEFAULT: "#0B1527",
            light: "#172542",
            dark: "#060C17",
            surface: "#111E36",
          },
          amber: {
            DEFAULT: "#F59E0B",
            hover: "#D97706",
            light: "#FEF3C7",
            muted: "#FBBF24",
          },
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
          accent: {
            green: "#10B981",
            red: "#EF4444",
            blue: "#3B82F6",
          }
        },
      },
      fontFamily: {
        sans: ["var(--font-inter)", "sans-serif"],
        display: ["var(--font-outfit)", "sans-serif"],
      },
      boxShadow: {
        card: "0 4px 20px -2px rgba(11, 21, 39, 0.08)",
        cardHover: "0 10px 25px -4px rgba(11, 21, 39, 0.12)",
        glow: "0 0 25px -5px rgba(245, 158, 11, 0.3)",
      },
    },
  },
  plugins: [],
};

export default config;
