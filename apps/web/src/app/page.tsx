import React from "react";
import { api } from "@/lib/api";
import { HeroBanners } from "@/components/home/HeroBanners";
import { CategoryStrip } from "@/components/home/CategoryStrip";
import { FeaturedProducts } from "@/components/home/FeaturedProducts";
import { TrustFeatures } from "@/components/home/TrustFeatures";
import type { Banner, Category, Product } from "@buildmart/shared";

export const dynamic = "force-dynamic";

export default async function HomePage() {
  let banners: Banner[] = [];
  let categories: Category[] = [];
  let featuredProducts: Product[] = [];
  let cementProducts: Product[] = [];

  try {
    const [bRes, cRes, pRes, cmRes] = await Promise.allSettled([
      api.getBanners(),
      api.getCategories(),
      api.getProducts({ limit: 8, sort_by: "popular" }),
      api.getProducts({ category_id: "cement", limit: 4 }),
    ]);

    if (bRes.status === "fulfilled") banners = bRes.value;
    if (cRes.status === "fulfilled") categories = cRes.value;
    if (pRes.status === "fulfilled") featuredProducts = pRes.value;
    if (cmRes.status === "fulfilled") cementProducts = cmRes.value;
  } catch (error) {
    console.error("Error loading home page data:", error);
  }

  return (
    <div className="space-y-12">
      {/* Hero Carousel */}
      <HeroBanners banners={banners} />

      {/* Categories Navigation Strip */}
      <CategoryStrip categories={categories} />

      {/* Featured Products Grid */}
      <FeaturedProducts
        products={featuredProducts}
        title="Verified Wholesale Products"
        subtitle="Primary grade cement, structural steel, and building basics"
      />

      {/* Enterprise Trust Section */}
      <TrustFeatures />

      {/* Cement Spotlight */}
      {cementProducts.length > 0 && (
        <FeaturedProducts
          products={cementProducts}
          title="Direct Cement Mill Shipments"
          subtitle="OPC 53 Grade & PPC bags delivered in truckloads directly to job sites"
        />
      )}
    </div>
  );
}
