"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { Star, Plus, Check, ShoppingCart, ArrowRight } from "lucide-react";
import type { Product } from "@buildmart/shared";
import { useCartStore } from "@/stores/cart-store";
import { formatCurrency } from "@/lib/utils";

interface FeaturedProductsProps {
  products: Product[];
  title?: string;
  subtitle?: string;
}

export const FeaturedProducts: React.FC<FeaturedProductsProps> = ({
  products,
  title = "Trending Wholesale Construction Materials",
  subtitle = "High turnover builder favorites ready for next-day delivery",
}) => {
  const { addItem, items } = useCartStore();

  return (
    <section className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display font-bold text-xl sm:text-2xl text-slate-900 tracking-tight">
            {title}
          </h2>
          <p className="text-xs sm:text-sm text-slate-500">{subtitle}</p>
        </div>
        <Link
          href="/products"
          className="text-xs sm:text-sm font-semibold text-amber-600 hover:text-amber-700 flex items-center gap-1 group"
        >
          <span>Explore All</span>
          <ArrowRight className="w-4 h-4 transform group-hover:translate-x-1 transition" />
        </Link>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 sm:gap-6">
        {products.map((prod) => {
          const discountPercent =
            prod.original_price && prod.original_price > prod.price
              ? Math.round(((prod.original_price - prod.price) / prod.original_price) * 100)
              : null;

          const isInCart = items.some((i) => (i.productId || i.product_id) === prod.id);

          return (
            <div
              key={prod.id}
              className="glass-card rounded-2xl p-4 flex flex-col justify-between hover:border-amber-400 hover:shadow-cardHover transition duration-200 group"
            >
              <div>
                {/* Image & Badges */}
                <div className="relative w-full h-48 rounded-xl overflow-hidden bg-slate-100 mb-3">
                  {prod.image_urls && prod.image_urls.length > 0 ? (
                    <Image
                      src={prod.image_urls[0]}
                      alt={prod.title}
                      fill
                      sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 25vw"
                      className="object-cover group-hover:scale-105 transition duration-300"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-slate-400 text-sm">
                      Construction Material
                    </div>
                  )}

                  {/* Discount Badge */}
                  {discountPercent && discountPercent > 0 && (
                    <span className="absolute top-2.5 left-2.5 bg-red-600 text-white font-black text-[10px] tracking-wider uppercase px-2 py-0.5 rounded-full shadow">
                      {discountPercent}% OFF
                    </span>
                  )}

                  {/* Category Pill */}
                  <span className="absolute bottom-2.5 left-2.5 bg-black/60 backdrop-blur-sm text-white text-[10px] font-semibold px-2 py-0.5 rounded-md capitalize">
                    {prod.category_id.replace("_", " ")}
                  </span>
                </div>

                {/* Rating */}
                <div className="flex items-center gap-1.5 mb-1.5">
                  <div className="flex items-center text-amber-500">
                    <Star className="w-3.5 h-3.5 fill-current" />
                    <span className="text-xs font-bold text-slate-800 ml-1">
                      {prod.rating.toFixed(1)}
                    </span>
                  </div>
                  <span className="text-[11px] text-slate-400">
                    ({prod.total_reviews} reviews)
                  </span>
                </div>

                {/* Title */}
                <Link href={`/products/${prod.id}`}>
                  <h3 className="font-semibold text-slate-900 text-sm line-clamp-2 hover:text-amber-600 transition leading-snug">
                    {prod.title}
                  </h3>
                </Link>
              </div>

              {/* Price & Action */}
              <div className="pt-4 mt-2 border-t border-slate-100 flex items-center justify-between">
                <div>
                  <div className="flex items-baseline gap-1.5">
                    <span className="font-extrabold text-base text-slate-900">
                      {formatCurrency(prod.price)}
                    </span>
                    {prod.original_price && prod.original_price > prod.price && (
                      <span className="text-xs text-slate-400 line-through">
                        {formatCurrency(prod.original_price)}
                      </span>
                    )}
                  </div>
                  <span className="text-[11px] text-slate-500 block -mt-0.5">
                    per {prod.unit || "unit"}
                  </span>
                </div>

                {/* Add to Cart Button */}
                <button
                  onClick={() => addItem(prod, 1)}
                  className={`p-2.5 rounded-xl font-bold transition flex items-center justify-center transform active:scale-95 shadow-sm ${
                    isInCart
                      ? "bg-emerald-500 text-white hover:bg-emerald-600"
                      : "bg-amber-500 hover:bg-amber-400 text-buildmart-navy"
                  }`}
                  aria-label={`Add ${prod.title} to cart`}
                  title={isInCart ? "In your cart" : "Add to cart"}
                >
                  {isInCart ? <Check className="w-4 h-4" /> : <Plus className="w-4 h-4" />}
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
};
