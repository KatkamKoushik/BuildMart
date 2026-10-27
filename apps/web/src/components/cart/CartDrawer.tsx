"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { X, Plus, Minus, Trash2, ShoppingBag, ArrowRight, ShieldCheck } from "lucide-react";
import { useCartStore } from "@/stores/cart-store";
import { formatCurrency } from "@/lib/utils";

export const CartDrawer: React.FC = () => {
  const {
    isOpen,
    setIsOpen,
    items,
    subtotal,
    tax,
    deliveryFee,
    total,
    totalCount,
    updateQuantity,
    removeItem,
    isLoading,
  } = useCartStore();

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-hidden" id="cart-drawer-modal">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm transition-opacity"
        onClick={() => setIsOpen(false)}
      />

      <div className="fixed inset-y-0 right-0 max-w-full flex pl-10">
        <div className="w-screen max-w-md bg-white shadow-2xl flex flex-col">
          {/* Header */}
          <div className="p-5 bg-buildmart-navy text-white flex items-center justify-between border-b border-slate-800">
            <div className="flex items-center gap-2.5">
              <ShoppingBag className="w-5 h-5 text-amber-400" />
              <h2 className="font-display font-bold text-lg">
                Your Cart ({totalCount} {totalCount === 1 ? "item" : "items"})
              </h2>
            </div>
            <button
              onClick={() => setIsOpen(false)}
              className="p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-white/10 transition"
              id="cart-drawer-close"
              aria-label="Close cart drawer"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Cart Items List */}
          <div className="flex-1 overflow-y-auto p-5 space-y-4">
            {items.length === 0 ? (
              <div className="text-center py-16 space-y-4">
                <div className="w-20 h-20 mx-auto rounded-full bg-slate-100 flex items-center justify-center text-slate-400">
                  <ShoppingBag className="w-10 h-10" />
                </div>
                <div className="space-y-1">
                  <h3 className="font-semibold text-slate-800 text-lg">Your cart is empty</h3>
                  <p className="text-sm text-slate-500 max-w-xs mx-auto">
                    Explore our direct factory prices on cement, steel, plumbing, and tools.
                  </p>
                </div>
                <button
                  onClick={() => setIsOpen(false)}
                  className="bg-amber-500 hover:bg-amber-600 text-buildmart-navy font-bold px-6 py-2.5 rounded-xl text-sm transition"
                >
                  Start Shopping
                </button>
              </div>
            ) : (
              items.map((item) => (
                <div
                  key={item.id}
                  className="flex gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-slate-50/50 hover:bg-white hover:shadow-sm transition"
                >
                  {/* Thumbnail */}
                  <div className="relative w-18 h-18 w-[72px] h-[72px] rounded-lg overflow-hidden bg-slate-200 flex-shrink-0">
                    {item.imageUrl ? (
                      <Image
                        src={item.imageUrl}
                        alt={item.title}
                        fill
                        sizes="72px"
                        className="object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-xs text-slate-400">
                        Material
                      </div>
                    )}
                  </div>

                  {/* Details */}
                  <div className="flex-1 min-w-0 flex flex-col justify-between">
                    <div>
                      <h4 className="font-medium text-slate-900 text-sm line-clamp-1">
                        {item.title}
                      </h4>
                      <p className="text-xs text-slate-500 mt-0.5">
                        {formatCurrency(item.price)} / {item.unit || "unit"}
                      </p>
                    </div>

                    <div className="flex items-center justify-between mt-2">
                      {/* Quantity Controls */}
                      <div className="flex items-center border border-slate-300 rounded-lg bg-white">
                        <button
                          onClick={() => updateQuantity(item.id, item.quantity - 1)}
                          className="p-1 hover:bg-slate-100 text-slate-600 rounded-l-lg transition"
                          disabled={isLoading}
                          aria-label="Decrease quantity"
                        >
                          <Minus className="w-3.5 h-3.5" />
                        </button>
                        <span className="px-2.5 text-xs font-semibold text-slate-800">
                          {item.quantity}
                        </span>
                        <button
                          onClick={() => updateQuantity(item.id, item.quantity + 1)}
                          className="p-1 hover:bg-slate-100 text-slate-600 rounded-r-lg transition"
                          disabled={isLoading}
                          aria-label="Increase quantity"
                        >
                          <Plus className="w-3.5 h-3.5" />
                        </button>
                      </div>

                      {/* Item Total & Remove */}
                      <div className="flex items-center gap-3">
                        <span className="font-bold text-sm text-slate-900">
                          {formatCurrency(item.price * item.quantity)}
                        </span>
                        <button
                          onClick={() => removeItem(item.id)}
                          className="text-slate-400 hover:text-red-500 transition p-1"
                          title="Remove item"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Footer Summary & Checkout */}
          {items.length > 0 && (
            <div className="p-5 bg-slate-50 border-t border-slate-200 space-y-3">
              <div className="space-y-1.5 text-xs text-slate-600">
                <div className="flex justify-between">
                  <span>Subtotal</span>
                  <span className="font-medium text-slate-900">{formatCurrency(subtotal)}</span>
                </div>
                <div className="flex justify-between">
                  <span>GST (18% Construction Material Tax)</span>
                  <span className="font-medium text-slate-900">{formatCurrency(tax)}</span>
                </div>
                <div className="flex justify-between">
                  <span>Site Delivery Fee</span>
                  <span className="font-medium text-slate-900">
                    {deliveryFee === 0 ? (
                      <strong className="text-emerald-600 font-bold uppercase text-[10px]">FREE</strong>
                    ) : (
                      formatCurrency(deliveryFee)
                    )}
                  </span>
                </div>
                <div className="pt-2 border-t border-slate-200 flex justify-between text-base font-bold text-slate-900">
                  <span>Estimated Total</span>
                  <span className="text-buildmart-navy text-lg">{formatCurrency(total)}</span>
                </div>
              </div>

              {/* Delivery Note */}
              <div className="flex items-center gap-2 p-2.5 bg-emerald-50 rounded-lg text-emerald-800 text-[11px]">
                <ShieldCheck className="w-4 h-4 text-emerald-600 flex-shrink-0" />
                <span>GST Tax Invoice with Input Credit eligibility issued with order.</span>
              </div>

              {/* Checkout Action */}
              <Link
                href="/checkout"
                onClick={() => setIsOpen(false)}
                className="w-full bg-amber-500 hover:bg-amber-600 text-buildmart-navy font-bold py-3.5 px-4 rounded-xl flex items-center justify-center gap-2 shadow-lg transition active:scale-98"
                id="cart-drawer-checkout-btn"
              >
                <span>Proceed to Site Checkout</span>
                <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
