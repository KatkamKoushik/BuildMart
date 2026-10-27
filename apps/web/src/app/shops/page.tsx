import React from "react";
import Image from "next/image";
import Link from "next/link";
import { api } from "@/lib/api";
import type { Shop } from "@buildmart/shared";
import { Store, Star, MapPin, Phone, ArrowRight, CheckCircle2 } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function ShopsPage() {
  let shops: Shop[] = [];
  try {
    shops = await api.getShops();
  } catch (err) {
    console.error("Failed to load shops:", err);
  }

  return (
    <div className="space-y-8 max-w-6xl mx-auto">
      <div>
        <h1 className="font-display font-black text-2xl sm:text-3xl text-slate-900">
          Authorized Material Yards & Suppliers
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Direct manufacturer-affiliated distribution hubs with guaranteed stock and rapid dispatch
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {shops.map((shop) => (
          <div
            key={shop.id}
            className="glass-card rounded-2xl overflow-hidden flex flex-col justify-between hover:border-amber-400 hover:shadow-cardHover transition duration-200 group"
          >
            <div>
              {/* Cover Photo */}
              <div className="relative w-full h-44 bg-slate-200">
                {shop.cover_image_url ? (
                  <Image
                    src={shop.cover_image_url}
                    alt={shop.name}
                    fill
                    sizes="(max-width: 768px) 100vw, 33vw"
                    className="object-cover group-hover:scale-105 transition duration-300"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-slate-400">
                    Distribution Yard
                  </div>
                )}
                {/* Distance Badge */}
                <span className="absolute top-3 right-3 bg-black/60 backdrop-blur-sm text-white text-xs font-bold px-2.5 py-1 rounded-full">
                  {shop.distance_km || 1.5} km away
                </span>
              </div>

              {/* Body */}
              <div className="p-5 space-y-3">
                <div className="flex items-start justify-between gap-2">
                  <h3 className="font-display font-bold text-lg text-slate-900 line-clamp-1 group-hover:text-amber-600 transition">
                    {shop.name}
                  </h3>
                  <div className="flex items-center gap-1 bg-amber-50 px-2 py-0.5 rounded text-amber-700 text-xs font-bold">
                    <Star className="w-3.5 h-3.5 fill-current text-amber-500" />
                    <span>{shop.rating.toFixed(1)}</span>
                  </div>
                </div>

                <div className="text-xs text-slate-500 space-y-1">
                  <p className="flex items-center gap-1.5">
                    <MapPin className="w-3.5 h-3.5 text-amber-500 flex-shrink-0" />
                    <span className="line-clamp-1">{shop.address}</span>
                  </p>
                  {shop.phone && (
                    <p className="flex items-center gap-1.5">
                      <Phone className="w-3.5 h-3.5 text-amber-500 flex-shrink-0" />
                      <span>{shop.phone}</span>
                    </p>
                  )}
                </div>

                {/* Categories badges */}
                {shop.categories && shop.categories.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 pt-1">
                    {shop.categories.map((cat, idx) => (
                      <span
                        key={idx}
                        className="text-[10px] bg-slate-100 text-slate-600 px-2 py-0.5 rounded-md capitalize font-medium"
                      >
                        {cat.replace("_", " ")}
                      </span>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Action */}
            <div className="p-5 pt-0">
              <Link
                href={`/products?shop_id=${shop.id}`}
                className="w-full bg-slate-900 hover:bg-buildmart-navy text-white text-xs font-bold py-2.5 px-4 rounded-xl flex items-center justify-center gap-1.5 transition"
              >
                <span>Browse Yard Inventory</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </Link>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
