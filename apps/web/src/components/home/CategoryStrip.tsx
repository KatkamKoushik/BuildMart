"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import type { Category } from "@buildmart/shared";
import { ArrowRight, Layers } from "lucide-react";

interface CategoryStripProps {
  categories: Category[];
}

export const CategoryStrip: React.FC<CategoryStripProps> = ({ categories }) => {
  return (
    <section className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display font-bold text-xl sm:text-2xl text-slate-900 tracking-tight">
            Shop by Material Category
          </h2>
          <p className="text-xs sm:text-sm text-slate-500">
            Certified raw materials sourced directly from authorized manufacturers
          </p>
        </div>
        <Link
          href="/products"
          className="text-xs sm:text-sm font-semibold text-amber-600 hover:text-amber-700 flex items-center gap-1 group"
        >
          <span>View All 16 Categories</span>
          <ArrowRight className="w-4 h-4 transform group-hover:translate-x-1 transition" />
        </Link>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-3 sm:gap-4">
        {categories.slice(0, 16).map((cat) => (
          <Link
            key={cat.id}
            href={`/products?category_id=${cat.id}`}
            className="group glass-card rounded-2xl p-3 flex flex-col items-center text-center hover:border-amber-400 hover:shadow-cardHover transition duration-200"
          >
            {/* Category Image */}
            <div className="relative w-16 h-16 sm:w-20 sm:h-20 rounded-xl overflow-hidden bg-slate-100 mb-2.5 flex-shrink-0 group-hover:scale-105 transition duration-300">
              {cat.imageUrl ? (
                <Image
                  src={cat.imageUrl}
                  alt={cat.name}
                  fill
                  sizes="80px"
                  className="object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-slate-400">
                  <Layers className="w-6 h-6" />
                </div>
              )}
            </div>

            {/* Name */}
            <span className="font-semibold text-xs text-slate-800 line-clamp-1 group-hover:text-amber-600 transition">
              {cat.name}
            </span>

            {/* Product Count */}
            {cat.productCount !== undefined && cat.productCount > 0 && (
              <span className="text-[10px] text-slate-400 mt-0.5">
                {cat.productCount} products
              </span>
            )}
          </Link>
        ))}
      </div>
    </section>
  );
};
