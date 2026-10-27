"use client";

import React, { useState } from "react";
import { Plus, Minus, ShoppingCart, Check, Zap } from "lucide-react";
import type { Product } from "@buildmart/shared";
import { useCartStore } from "@/stores/cart-store";
import { useRouter } from "next/navigation";

interface AddToCartButtonProps {
  product: Product;
}

export const AddToCartButton: React.FC<AddToCartButtonProps> = ({ product }) => {
  const router = useRouter();
  const [qty, setQty] = useState(1);
  const [added, setAdded] = useState(false);
  const { addItem, isLoading } = useCartStore();

  const handleAddToCart = async () => {
    await addItem(product, qty);
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  const handleDirectBuy = async () => {
    await addItem(product, qty);
    router.push("/checkout");
  };

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-4">
        {/* Quantity Selector */}
        <div className="flex items-center border border-slate-300 rounded-xl bg-white p-1">
          <button
            onClick={() => setQty(Math.max(1, qty - 1))}
            className="p-2 hover:bg-slate-100 rounded-lg text-slate-700 transition"
            aria-label="Decrease quantity"
          >
            <Minus className="w-4 h-4" />
          </button>
          <input
            type="number"
            min="1"
            value={qty}
            onChange={(e) => setQty(Math.max(1, parseInt(e.target.value) || 1))}
            className="w-16 text-center font-bold text-slate-900 focus:outline-none text-sm"
          />
          <button
            onClick={() => setQty(qty + 1)}
            className="p-2 hover:bg-slate-100 rounded-lg text-slate-700 transition"
            aria-label="Increase quantity"
          >
            <Plus className="w-4 h-4" />
          </button>
        </div>

        {/* Add to Cart */}
        <button
          onClick={handleAddToCart}
          disabled={isLoading}
          className={`flex-1 py-3.5 px-6 rounded-xl font-bold text-sm flex items-center justify-center gap-2 shadow-md transition transform active:scale-98 ${
            added
              ? "bg-emerald-600 text-white"
              : "bg-amber-500 hover:bg-amber-400 text-buildmart-navy shadow-glow"
          }`}
          id="product-add-to-cart-btn"
        >
          {added ? (
            <>
              <Check className="w-4 h-4" />
              <span>Added to Cart</span>
            </>
          ) : (
            <>
              <ShoppingCart className="w-4 h-4" />
              <span>Add to Cart ({qty} {product.unit || "units"})</span>
            </>
          )}
        </button>
      </div>

      {/* Direct Buy Button */}
      <button
        onClick={handleDirectBuy}
        className="w-full bg-buildmart-navy hover:bg-buildmart-navy-light text-white font-bold py-3 px-6 rounded-xl text-sm flex items-center justify-center gap-2 transition"
        id="product-buy-now-btn"
      >
        <Zap className="w-4 h-4 text-amber-400" />
        <span>Buy Now with Site Dispatch</span>
      </button>
    </div>
  );
};
