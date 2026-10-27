"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  Search,
  ShoppingCart,
  MapPin,
  FileText,
  Truck,
  Store,
  Menu,
  X,
  PhoneCall,
  ShieldCheck,
} from "lucide-react";
import { useCartStore } from "@/stores/cart-store";

export const Header: React.FC = () => {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState("");
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { totalCount, toggleCart, fetchCart } = useCartStore();

  useEffect(() => {
    fetchCart();
  }, [fetchCart]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      router.push(`/products?q=${encodeURIComponent(searchQuery.trim())}`);
    } else {
      router.push("/products");
    }
  };

  return (
    <header className="sticky top-0 z-40 w-full">
      {/* Top Notification Bar */}
      <div className="bg-buildmart-navy-dark text-slate-300 text-xs py-1.5 px-4 border-b border-white/10 hidden md:block">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <div className="flex items-center space-x-6">
            <span className="flex items-center text-amber-400 font-medium">
              <ShieldCheck className="w-3.5 h-3.5 mr-1.5" />
              100% Genuine Certified Building Materials
            </span>
            <span className="text-slate-400">|</span>
            <span>Free Delivery on orders above ₹5,000</span>
          </div>
          <div className="flex items-center space-x-4">
            <a href="tel:18002338899" className="flex items-center hover:text-white transition">
              <PhoneCall className="w-3 h-3 mr-1 text-amber-400" />
              Toll Free: 1800-233-8899
            </a>
            <span className="text-slate-400">|</span>
            <Link href="/quotes" className="hover:text-amber-400 transition font-medium">
              Contractor Bulk Desk
            </Link>
          </div>
        </div>
      </div>

      {/* Main Navigation Bar */}
      <div className="glass-header text-white px-4 py-3 sm:px-6">
        <div className="max-w-7xl mx-auto flex items-center justify-between gap-4">
          {/* Logo & Location */}
          <div className="flex items-center gap-5">
            <Link href="/" className="flex items-center gap-2 group" id="nav-brand-logo">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center font-display font-extrabold text-buildmart-navy text-xl shadow-glow">
                BM
              </div>
              <div className="flex flex-col">
                <span className="font-display font-black text-2xl tracking-tight text-white group-hover:text-amber-400 transition">
                  BUILD<span className="text-amber-400">MART</span>
                </span>
                <span className="text-[10px] tracking-widest text-slate-400 uppercase -mt-1 font-semibold">
                  Enterprise Construction
                </span>
              </div>
            </Link>

            {/* City Badge */}
            <div className="hidden lg:flex items-center text-xs bg-white/10 px-3 py-1.5 rounded-full border border-white/10 text-slate-200">
              <MapPin className="w-3.5 h-3.5 text-amber-400 mr-1.5" />
              <span>Deliver to: <strong className="text-white">Hyderabad (500081)</strong></span>
            </div>
          </div>

          {/* Search Bar */}
          <form
            onSubmit={handleSearchSubmit}
            className="flex-1 max-w-xl relative hidden md:block"
            id="header-search-form"
          >
            <div className="relative">
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search cement, steel rods, plumbing, bricks, tiles..."
                className="w-full bg-slate-900/80 border border-slate-700/80 rounded-xl pl-11 pr-24 py-2.5 text-sm text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent transition"
                id="header-search-input"
              />
              <Search className="absolute left-3.5 top-3 w-4 h-4 text-slate-400" />
              <button
                type="submit"
                className="absolute right-1.5 top-1.5 bg-amber-500 hover:bg-amber-600 text-buildmart-navy font-semibold px-4 py-1.5 rounded-lg text-xs transition"
                id="header-search-btn"
              >
                Search
              </button>
            </div>
          </form>

          {/* Action Links */}
          <div className="flex items-center gap-2 sm:gap-4">
            <Link
              href="/quotes"
              className="hidden sm:flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold text-slate-200 hover:text-white hover:bg-white/10 transition"
              id="nav-quote-link"
            >
              <FileText className="w-4 h-4 text-amber-400" />
              <span>Get Quote</span>
            </Link>

            <Link
              href="/shops"
              className="hidden sm:flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold text-slate-200 hover:text-white hover:bg-white/10 transition"
              id="nav-shops-link"
            >
              <Store className="w-4 h-4 text-amber-400" />
              <span>Suppliers</span>
            </Link>

            <Link
              href="/orders"
              className="hidden sm:flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold text-slate-200 hover:text-white hover:bg-white/10 transition"
              id="nav-orders-link"
            >
              <Truck className="w-4 h-4 text-amber-400" />
              <span>Orders</span>
            </Link>

            {/* Cart Trigger */}
            <button
              onClick={toggleCart}
              className="relative p-2.5 bg-amber-500 hover:bg-amber-400 text-buildmart-navy rounded-xl flex items-center justify-center font-bold shadow-md transition transform active:scale-95"
              id="header-cart-btn"
              aria-label="View shopping cart"
            >
              <ShoppingCart className="w-5 h-5" />
              {totalCount > 0 && (
                <span className="absolute -top-1.5 -right-1.5 bg-red-600 text-white text-[11px] font-extrabold w-5 h-5 rounded-full flex items-center justify-center border-2 border-buildmart-navy animate-pulse">
                  {totalCount}
                </span>
              )}
            </button>

            {/* Mobile Menu Toggle */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 text-slate-300 hover:text-white"
              aria-label="Toggle navigation menu"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>

        {/* Mobile Search Bar */}
        <div className="mt-3 md:hidden">
          <form onSubmit={handleSearchSubmit}>
            <div className="relative">
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search building materials..."
                className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-20 py-2 text-sm text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-400"
              />
              <Search className="absolute left-3 top-2.5 w-4 h-4 text-slate-400" />
              <button
                type="submit"
                className="absolute right-1 top-1 bg-amber-500 text-buildmart-navy font-bold px-3 py-1.5 rounded-lg text-xs"
              >
                Go
              </button>
            </div>
          </form>
        </div>

        {/* Mobile Navigation Drawer */}
        {mobileMenuOpen && (
          <div className="md:hidden mt-3 pt-3 border-t border-white/10 space-y-2">
            <Link
              href="/products"
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-sm font-medium hover:bg-white/10"
            >
              Browse All Products
            </Link>
            <Link
              href="/quotes"
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-sm font-medium hover:bg-white/10 flex items-center justify-between"
            >
              <span>Request Quote / Estimate</span>
              <FileText className="w-4 h-4 text-amber-400" />
            </Link>
            <Link
              href="/shops"
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-sm font-medium hover:bg-white/10 flex items-center justify-between"
            >
              <span>Nearby Suppliers & Yards</span>
              <Store className="w-4 h-4 text-amber-400" />
            </Link>
            <Link
              href="/orders"
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-sm font-medium hover:bg-white/10 flex items-center justify-between"
            >
              <span>Track Orders</span>
              <Truck className="w-4 h-4 text-amber-400" />
            </Link>
          </div>
        )}
      </div>
    </header>
  );
};
