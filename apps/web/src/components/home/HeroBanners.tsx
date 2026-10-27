"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import { ChevronLeft, ChevronRight, ArrowRight, ShieldCheck, Zap } from "lucide-react";
import type { Banner } from "@buildmart/shared";

interface HeroBannersProps {
  banners: Banner[];
}

export const HeroBanners: React.FC<HeroBannersProps> = ({ banners }) => {
  const [currentIndex, setCurrentIndex] = useState(0);

  const displayBanners = banners.length > 0 ? banners : [
    {
      id: "fallback_1",
      title: "Direct-From-Manufacturer Construction Supply",
      subtitle: "Cement, TMT Steel, Aggregates & Plumbing with Site Delivery",
      imageUrl: "https://images.unsplash.com/photo-1541888946425-d0fbb18615f8?auto=format&fit=crop&q=80&w=1600&h=600",
      targetCategory: "cement",
      discountText: "UP TO 30% OFF WHOLESALE",
    },
  ];

  useEffect(() => {
    if (displayBanners.length <= 1) return;
    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % displayBanners.length);
    }, 6000);
    return () => clearInterval(interval);
  }, [displayBanners.length]);

  const current = displayBanners[currentIndex];

  const handlePrev = () => {
    setCurrentIndex((prev) => (prev - 1 + displayBanners.length) % displayBanners.length);
  };

  const handleNext = () => {
    setCurrentIndex((prev) => (prev + 1) % displayBanners.length);
  };

  return (
    <div className="relative w-full rounded-2xl overflow-hidden bg-buildmart-navy shadow-xl border border-slate-800">
      <div className="relative h-[320px] sm:h-[400px] md:h-[460px] w-full">
        {/* Background Image */}
        {current.imageUrl && (
          <Image
            src={current.imageUrl}
            alt={current.title}
            fill
            priority
            sizes="100vw"
            className="object-cover opacity-35 transition-all duration-700 scale-105"
          />
        )}

        {/* Gradient Overlay */}
        <div className="absolute inset-0 bg-gradient-to-r from-buildmart-navy-dark via-buildmart-navy/90 to-transparent flex items-center">
          <div className="max-w-2xl p-6 sm:p-12 space-y-4">
            {/* Tag */}
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-amber-500/20 border border-amber-400/30 text-amber-300 text-xs font-bold uppercase tracking-wider">
              <Zap className="w-3.5 h-3.5 text-amber-400" />
              <span>{current.discountText || "FACTORY-DIRECT PRICING"}</span>
            </div>

            {/* Title */}
            <h1 className="font-display font-extrabold text-2xl sm:text-4xl md:text-5xl text-white leading-tight tracking-tight">
              {current.title}
            </h1>

            {/* Subtitle */}
            <p className="text-sm sm:text-base text-slate-300 max-w-xl font-normal leading-relaxed">
              {current.subtitle || "Order high-specification certified materials with live fleet tracking and GST tax invoices directly to your site."}
            </p>

            {/* Action Buttons */}
            <div className="flex flex-wrap items-center gap-3 pt-2">
              <Link
                href={`/products${current.targetCategory ? `?category_id=${current.targetCategory}` : ""}`}
                className="bg-amber-500 hover:bg-amber-400 text-buildmart-navy font-bold px-6 py-3 rounded-xl text-sm flex items-center gap-2 shadow-glow transition transform active:scale-95"
                id="hero-banner-cta-primary"
              >
                <span>Order Now</span>
                <ArrowRight className="w-4 h-4" />
              </Link>

              <Link
                href="/quotes"
                className="bg-white/10 hover:bg-white/20 text-white font-semibold px-6 py-3 rounded-xl text-sm border border-white/20 backdrop-blur-sm transition"
                id="hero-banner-cta-quote"
              >
                Request Commercial Estimate
              </Link>
            </div>
          </div>
        </div>

        {/* Controls */}
        {displayBanners.length > 1 && (
          <>
            <button
              onClick={handlePrev}
              className="absolute left-4 top-1/2 -translate-y-1/2 p-2 rounded-full bg-black/40 hover:bg-black/70 text-white border border-white/20 backdrop-blur-sm transition"
              aria-label="Previous banner"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
            <button
              onClick={handleNext}
              className="absolute right-4 top-1/2 -translate-y-1/2 p-2 rounded-full bg-black/40 hover:bg-black/70 text-white border border-white/20 backdrop-blur-sm transition"
              aria-label="Next banner"
            >
              <ChevronRight className="w-5 h-5" />
            </button>

            {/* Pagination Dots */}
            <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex items-center gap-2">
              {displayBanners.map((_, i) => (
                <button
                  key={i}
                  onClick={() => setCurrentIndex(i)}
                  className={`h-2 rounded-full transition-all ${
                    currentIndex === i ? "w-6 bg-amber-400" : "w-2 bg-white/40 hover:bg-white/70"
                  }`}
                  aria-label={`Go to slide ${i + 1}`}
                />
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
};
