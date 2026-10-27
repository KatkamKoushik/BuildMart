import type { Metadata } from "next";
import "./globals.css";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { CartDrawer } from "@/components/cart/CartDrawer";

export const metadata: Metadata = {
  title: "BuildMart | Certified Construction Materials & Bulk Procurement",
  description:
    "Direct-from-manufacturer cement, TMT steel, aggregates, plumbing, electricals, and building materials. Fast job site delivery, wholesale commercial quotes, and verified quality.",
  keywords: [
    "construction materials",
    "cement wholesale",
    "TMT steel rods",
    "building supplies Hyderabad",
    "UltraTech cement",
    "Tata Tiscon",
    "contractor procurement",
    "BuildMart",
  ],
  authors: [{ name: "BuildMart Technologies" }],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="flex flex-col min-h-screen bg-slate-50 text-slate-900 antialiased selection:bg-amber-400 selection:text-buildmart-navy">
        <Header />
        <main className="flex-1 w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          {children}
        </main>
        <CartDrawer />
        <Footer />
      </body>
    </html>
  );
}
