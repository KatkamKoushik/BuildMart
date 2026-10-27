import React from "react";
import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { api } from "@/lib/api";
import { formatCurrency } from "@/lib/utils";
import {
  Star,
  ShieldCheck,
  Truck,
  CheckCircle2,
  ChevronRight,
  FileText,
  Store,
  Layers,
  ArrowLeft,
} from "lucide-react";
import { AddToCartButton } from "./AddToCartButton";

interface ProductPageProps {
  params: Promise<{ id: string }>;
}

export const dynamic = "force-dynamic";

export default async function ProductDetailPage({ params }: ProductPageProps) {
  const { id } = await params;

  let product;
  let shop;
  try {
    product = await api.getProduct(id);
    if (product.shop_id) {
      try {
        shop = await api.getShop(product.shop_id);
      } catch {}
    }
  } catch (e) {
    notFound();
  }

  const discountPercent =
    product.original_price && product.original_price > product.price
      ? Math.round(((product.original_price - product.price) / product.original_price) * 100)
      : null;

  return (
    <div className="space-y-8">
      {/* Breadcrumbs */}
      <div className="flex items-center gap-1.5 text-xs text-slate-500">
        <Link href="/" className="hover:text-amber-600">Home</Link>
        <ChevronRight className="w-3 h-3" />
        <Link href="/products" className="hover:text-amber-600">Products</Link>
        <ChevronRight className="w-3 h-3" />
        <Link
          href={`/products?category_id=${product.category_id}`}
          className="hover:text-amber-600 capitalize"
        >
          {product.category_id.replace("_", " ")}
        </Link>
        <ChevronRight className="w-3 h-3" />
        <span className="text-slate-800 font-semibold line-clamp-1">{product.title}</span>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-10">
        {/* Left: Product Media Gallery */}
        <div className="space-y-4">
          <div className="relative w-full h-[360px] sm:h-[460px] rounded-3xl overflow-hidden bg-white border border-slate-200 shadow-sm">
            {product.image_urls && product.image_urls.length > 0 ? (
              <Image
                src={product.image_urls[0]}
                alt={product.title}
                fill
                priority
                sizes="(max-width: 1024px) 100vw, 50vw"
                className="object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-slate-400">
                Material Illustration
              </div>
            )}

            {discountPercent && discountPercent > 0 && (
              <span className="absolute top-4 left-4 bg-red-600 text-white font-black text-xs px-3 py-1 rounded-full shadow-md">
                {discountPercent}% WHOLESALE SAVINGS
              </span>
            )}
          </div>

          {/* Thumbnail Strip */}
          {product.image_urls && product.image_urls.length > 1 && (
            <div className="flex gap-3 overflow-x-auto pb-2">
              {product.image_urls.map((img: string, i: number) => (
                <div
                  key={i}
                  className="relative w-20 h-20 rounded-xl overflow-hidden bg-white border border-slate-200 flex-shrink-0"
                >
                  <Image src={img} alt={`View ${i + 1}`} fill sizes="80px" className="object-cover" />
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Right: Product Info & Buy Box */}
        <div className="space-y-6">
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <span className="bg-amber-100 text-amber-800 font-bold text-[11px] px-2.5 py-0.5 rounded-full uppercase tracking-wider">
                {product.category_id.replace("_", " ")}
              </span>
              <span className="text-emerald-700 font-semibold text-xs flex items-center gap-1">
                <CheckCircle2 className="w-3.5 h-3.5" />
                In Stock ({product.stock_quantity} available)
              </span>
            </div>

            <h1 className="font-display font-black text-2xl sm:text-3xl text-slate-900 leading-tight">
              {product.title}
            </h1>

            {/* Rating */}
            <div className="flex items-center gap-2">
              <div className="flex items-center text-amber-500">
                {[...Array(5)].map((_, i) => (
                  <Star
                    key={i}
                    className={`w-4 h-4 ${
                      i < Math.floor(product.rating)
                        ? "fill-current"
                        : "text-slate-300 fill-slate-200"
                    }`}
                  />
                ))}
                <span className="font-bold text-slate-900 text-sm ml-1.5">
                  {product.rating.toFixed(1)}
                </span>
              </div>
              <span className="text-xs text-slate-500">
                ({product.total_reviews} verified builder reviews)
              </span>
            </div>
          </div>

          {/* Price Box */}
          <div className="p-5 rounded-2xl bg-slate-50 border border-slate-200 space-y-2">
            <div className="flex items-baseline gap-3">
              <span className="font-display font-extrabold text-3xl text-slate-900">
                {formatCurrency(product.price)}
              </span>
              {product.original_price && product.original_price > product.price && (
                <span className="text-base text-slate-400 line-through">
                  {formatCurrency(product.original_price)}
                </span>
              )}
              <span className="text-xs font-semibold text-slate-600">
                / {product.unit || "unit"} (incl. 18% GST)
              </span>
            </div>
            <p className="text-xs text-emerald-700 font-medium flex items-center gap-1.5">
              <ShieldCheck className="w-4 h-4 text-emerald-600" />
              Eligible for Full GST Input Tax Credit with valid Tax Invoice
            </p>
          </div>

          {/* Add to Cart Actions */}
          <AddToCartButton product={product} />

          {/* Specifications Table */}
          {product.specifications && Object.keys(product.specifications).length > 0 && (
            <div className="space-y-3 pt-4 border-t border-slate-200">
              <h3 className="font-bold text-slate-900 text-sm flex items-center gap-2">
                <Layers className="w-4 h-4 text-amber-500" />
                <span>Technical Specifications</span>
              </h3>
              <div className="rounded-xl border border-slate-200 overflow-hidden text-xs">
                {Object.entries(product.specifications).map(([key, val], idx) => (
                  <div
                    key={key}
                    className={`flex justify-between p-2.5 ${
                      idx % 2 === 0 ? "bg-slate-50" : "bg-white"
                    }`}
                  >
                    <span className="font-semibold text-slate-600">{key}</span>
                    <span className="font-medium text-slate-900">{String(val)}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Description */}
          <div className="space-y-2 pt-2">
            <h3 className="font-bold text-slate-900 text-sm">Product Description</h3>
            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed">
              {product.description ||
                "Industrial-grade building material produced in conformance with national BIS structural codes. Ideal for commercial foundations, slab casting, and reinforced construction."}
            </p>
          </div>

          {/* Yard / Seller Card */}
          {shop && (
            <div className="p-4 rounded-2xl bg-amber-50/50 border border-amber-200/60 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-amber-500/20 text-amber-700 flex items-center justify-center font-bold">
                  <Store className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="font-bold text-slate-900 text-xs">{shop.name}</h4>
                  <p className="text-[11px] text-slate-500">{shop.address}</p>
                </div>
              </div>
              <span className="text-[11px] bg-white px-2.5 py-1 rounded-full border border-amber-200 text-amber-800 font-bold">
                {shop.distance_km || 1.5} km away
              </span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
