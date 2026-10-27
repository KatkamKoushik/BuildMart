import React from "react";
import Link from "next/link";
import { api } from "@/lib/api";
import { FeaturedProducts } from "@/components/home/FeaturedProducts";
import type { Category, Product } from "@buildmart/shared";
import { Filter, SlidersHorizontal, ChevronRight, RotateCcw } from "lucide-react";

interface ProductsPageProps {
  searchParams: Promise<{
    category_id?: string;
    brand_id?: string;
    q?: string;
    sort_by?: string;
    min_price?: string;
    max_price?: string;
  }>;
}

export const dynamic = "force-dynamic";

export default async function ProductsPage({ searchParams }: ProductsPageProps) {
  const params = await searchParams;
  const currentCategory = params.category_id;
  const searchQuery = params.q;
  const currentSort = params.sort_by || "popular";

  let categories: Category[] = [];
  let products: Product[] = [];

  try {
    const [catList, prodList] = await Promise.all([
      api.getCategories(),
      api.getProducts({
        category_id: currentCategory,
        q: searchQuery,
        sort_by: currentSort,
        limit: 100,
      }),
    ]);
    categories = catList;
    products = prodList;
  } catch (err) {
    console.error("Error fetching catalog products:", err);
  }

  const selectedCategoryObj = categories.find((c) => c.id === currentCategory);

  return (
    <div className="space-y-6">
      {/* Breadcrumb & Title */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-200 pb-4">
        <div>
          <div className="flex items-center gap-1.5 text-xs text-slate-500 mb-1">
            <Link href="/" className="hover:text-amber-600">Home</Link>
            <ChevronRight className="w-3 h-3" />
            <Link href="/products" className="hover:text-amber-600">Products</Link>
            {selectedCategoryObj && (
              <>
                <ChevronRight className="w-3 h-3" />
                <span className="text-slate-800 font-semibold">{selectedCategoryObj.name}</span>
              </>
            )}
            {searchQuery && (
              <>
                <ChevronRight className="w-3 h-3" />
                <span className="text-slate-800 font-semibold">&ldquo;{searchQuery}&rdquo;</span>
              </>
            )}
          </div>

          <h1 className="font-display font-black text-2xl sm:text-3xl text-slate-900 tracking-tight">
            {selectedCategoryObj
              ? selectedCategoryObj.name
              : searchQuery
              ? `Search Results for "${searchQuery}"`
              : "All Construction Materials"}
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
            Showing {products.length} verified products with direct site dispatch
          </p>
        </div>

        {/* Sort & Reset Actions */}
        <div className="flex items-center gap-3">
          <form method="GET" className="flex items-center gap-2">
            {currentCategory && <input type="hidden" name="category_id" value={currentCategory} />}
            {searchQuery && <input type="hidden" name="q" value={searchQuery} />}

            <label htmlFor="sort_by" className="text-xs text-slate-500 font-medium whitespace-nowrap">
              Sort by:
            </label>
            <select
              id="sort_by"
              name="sort_by"
              defaultValue={currentSort}
              className="bg-white border border-slate-300 rounded-xl px-3 py-2 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-amber-400"
            >
              <option value="popular">Most Popular</option>
              <option value="price_low">Price: Low to High</option>
              <option value="price_high">Price: High to Low</option>
              <option value="rating">Highest Rated</option>
            </select>
            <button
              type="submit"
              className="bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold px-3 py-2 rounded-xl transition"
            >
              Apply
            </button>
          </form>

          {(currentCategory || searchQuery) && (
            <Link
              href="/products"
              className="flex items-center gap-1 text-xs text-red-600 hover:text-red-700 p-2 rounded-lg hover:bg-red-50 transition"
              title="Reset all filters"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Reset</span>
            </Link>
          )}
        </div>
      </div>

      {/* Main Grid: Categories Sidebar + Products */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* Category Filter Sidebar */}
        <aside className="lg:col-span-1 space-y-6">
          <div className="glass-card rounded-2xl p-4 space-y-4">
            <div className="flex items-center gap-2 font-bold text-slate-900 text-sm border-b border-slate-100 pb-2.5">
              <Filter className="w-4 h-4 text-amber-500" />
              <span>Filter by Category</span>
            </div>

            <ul className="space-y-1 text-xs">
              <li>
                <Link
                  href="/products"
                  className={`block px-3 py-2 rounded-xl font-medium transition ${
                    !currentCategory
                      ? "bg-amber-500 text-buildmart-navy font-bold shadow-sm"
                      : "text-slate-700 hover:bg-slate-100"
                  }`}
                >
                  All Categories
                </Link>
              </li>
              {categories.map((cat) => {
                const isActive = currentCategory === cat.id;
                return (
                  <li key={cat.id}>
                    <Link
                      href={`/products?category_id=${cat.id}${searchQuery ? `&q=${encodeURIComponent(searchQuery)}` : ""}`}
                      className={`flex items-center justify-between px-3 py-2 rounded-xl transition ${
                        isActive
                          ? "bg-amber-500 text-buildmart-navy font-bold shadow-sm"
                          : "text-slate-700 hover:bg-slate-100"
                      }`}
                    >
                      <span>{cat.name}</span>
                      {cat.productCount !== undefined && (
                        <span
                          className={`text-[10px] px-1.5 py-0.5 rounded-full ${
                            isActive
                              ? "bg-buildmart-navy text-white"
                              : "bg-slate-200 text-slate-600"
                          }`}
                        >
                          {cat.productCount}
                        </span>
                      )}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        </aside>

        {/* Product Cards Grid */}
        <div className="lg:col-span-3">
          {products.length === 0 ? (
            <div className="text-center py-20 bg-white rounded-3xl border border-slate-200 p-8 space-y-4">
              <div className="w-16 h-16 mx-auto rounded-full bg-amber-50 text-amber-600 flex items-center justify-center">
                <SlidersHorizontal className="w-8 h-8" />
              </div>
              <h3 className="font-bold text-slate-800 text-lg">No matching materials found</h3>
              <p className="text-sm text-slate-500 max-w-md mx-auto">
                Try searching with broader terms or clear category filters to view full inventory.
              </p>
              <Link
                href="/products"
                className="inline-block bg-amber-500 hover:bg-amber-600 text-buildmart-navy font-bold px-6 py-2.5 rounded-xl text-sm transition"
              >
                Reset Filters & View All
              </Link>
            </div>
          ) : (
            <FeaturedProducts
              products={products}
              title=""
              subtitle=""
            />
          )}
        </div>
      </div>
    </div>
  );
}
