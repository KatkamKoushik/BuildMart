import type {
  Category,
  Brand,
  Shop,
  Product,
  Banner,
  CartSummary,
  Order,
  QuoteRequest
} from "@buildmart/shared";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";

async function fetchJson<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const url = `${API_BASE_URL}${endpoint}`;
  const headers = {
    "Content-Type": "application/json",
    ...(options.headers || {}),
  };

  try {
    const res = await fetch(url, {
      ...options,
      headers,
      cache: options.cache || "no-store",
    });

    if (!res.ok) {
      let errMessage = `API Error ${res.status}: ${res.statusText}`;
      try {
        const errData = await res.json();
        if (errData && errData.detail) {
          errMessage = typeof errData.detail === "string" ? errData.detail : JSON.stringify(errData.detail);
        }
      } catch {}
      throw new Error(errMessage);
    }

    return await res.json();
  } catch (error: any) {
    console.error(`Fetch error at ${endpoint}:`, error);
    throw error;
  }
}

export const api = {
  // Categories
  async getCategories(): Promise<Category[]> {
    return fetchJson<Category[]>("/categories");
  },

  async getCategory(id: string): Promise<Category> {
    return fetchJson<Category>(`/categories/${id}`);
  },

  // Brands
  async getBrands(categoryId?: string): Promise<Brand[]> {
    const query = categoryId ? `?category_id=${encodeURIComponent(categoryId)}` : "";
    return fetchJson<Brand[]>(`/brands${query}`);
  },

  // Banners
  async getBanners(): Promise<Banner[]> {
    return fetchJson<Banner[]>("/banners");
  },

  // Shops
  async getShops(): Promise<Shop[]> {
    return fetchJson<Shop[]>("/shops");
  },

  async getShop(id: string): Promise<Shop> {
    return fetchJson<Shop>(`/shops/${id}`);
  },

  async getShopProducts(shopId: string): Promise<Product[]> {
    return fetchJson<Product[]>(`/shops/${shopId}/products`);
  },

  // Products
  async getProducts(params: {
    category_id?: string;
    brand_id?: string;
    shop_id?: string;
    q?: string;
    min_price?: number;
    max_price?: number;
    sort_by?: string;
    limit?: number;
    page?: number;
  } = {}): Promise<Product[]> {
    const searchParams = new URLSearchParams();
    if (params.category_id) searchParams.set("category_id", params.category_id);
    if (params.brand_id) searchParams.set("brand_id", params.brand_id);
    if (params.shop_id) searchParams.set("shop_id", params.shop_id);
    if (params.q) searchParams.set("q", params.q);
    if (params.min_price !== undefined) searchParams.set("min_price", params.min_price.toString());
    if (params.max_price !== undefined) searchParams.set("max_price", params.max_price.toString());
    if (params.sort_by) searchParams.set("sort_by", params.sort_by);
    if (params.limit) searchParams.set("limit", params.limit.toString());
    if (params.page) searchParams.set("page", params.page.toString());

    const qs = searchParams.toString();
    return fetchJson<Product[]>(`/products${qs ? `?${qs}` : ""}`);
  },

  async getProduct(id: string): Promise<Product> {
    return fetchJson<Product>(`/products/${id}`);
  },

  // Cart
  async getCart(): Promise<CartSummary> {
    return fetchJson<CartSummary>("/cart");
  },

  async addToCart(productId: string, quantity: number = 1): Promise<CartSummary> {
    return fetchJson<CartSummary>("/cart/items", {
      method: "POST",
      body: JSON.stringify({ product_id: productId, quantity }),
    });
  },

  async updateCartItem(itemId: string, quantity: number): Promise<CartSummary> {
    return fetchJson<CartSummary>(`/cart/items/${itemId}`, {
      method: "PUT",
      body: JSON.stringify({ quantity }),
    });
  },

  async removeCartItem(itemId: string): Promise<CartSummary> {
    return fetchJson<CartSummary>(`/cart/items/${itemId}`, {
      method: "DELETE",
    });
  },

  async clearCart(): Promise<void> {
    await fetch(`${API_BASE_URL}/cart`, { method: "DELETE" });
  },

  // Checkout & Payments
  async createRazorpayOrder(amount: number, receipt?: string) {
    return fetchJson<{ order_id: string; amount: number; currency: string; key_id: string }>(
      "/checkout/razorpay/create-order",
      {
        method: "POST",
        body: JSON.stringify({ amount, currency: "INR", receipt }),
      }
    );
  },

  async verifyRazorpayPayment(payload: {
    razorpay_order_id: string;
    razorpay_payment_id: string;
    razorpay_signature: string;
    order_id?: string;
  }) {
    return fetchJson<{ verified: boolean; message: string }>("/checkout/razorpay/verify", {
      method: "POST",
      body: JSON.stringify(payload),
    });
  },

  // Orders
  async createOrder(payload: {
    delivery_address: any;
    payment_method: string;
    items?: any[];
  }): Promise<Order> {
    return fetchJson<Order>("/orders", {
      method: "POST",
      body: JSON.stringify(payload),
    });
  },

  async getOrders(): Promise<Order[]> {
    return fetchJson<Order[]>("/orders");
  },

  async getOrder(id: string): Promise<Order> {
    return fetchJson<Order>(`/orders/${id}`);
  },

  async cancelOrder(id: string): Promise<Order> {
    return fetchJson<Order>(`/orders/${id}/cancel`, {
      method: "POST",
    });
  },

  // Quotes
  async submitQuote(payload: {
    customer_name: string;
    email: string;
    phone: string;
    project_name?: string;
    delivery_pincode: string;
    items: Array<{ title: string; quantity: number; unit: string; notes?: string }>;
  }): Promise<QuoteRequest> {
    return fetchJson<QuoteRequest>("/quotes", {
      method: "POST",
      body: JSON.stringify(payload),
    });
  },

  getQuotePdfUrl(quoteId: string): string {
    return `${API_BASE_URL}/quotes/${quoteId}/pdf`;
  },
};
