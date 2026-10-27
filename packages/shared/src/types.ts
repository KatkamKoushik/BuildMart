export type UserRole = "buyer" | "vendor" | "admin";

export interface Address {
  id?: string;
  fullName?: string;
  full_name?: string;
  addressLine1?: string;
  address_line_1?: string;
  addressLine2?: string;
  address_line_2?: string;
  city: string;
  state: string;
  postalCode?: string;
  postal_code?: string;
  phone: string;
  isDefault?: boolean;
  is_default?: boolean;
}

export interface User {
  id: string;
  firebaseUid?: string;
  firebase_uid?: string;
  name: string;
  email: string;
  phone?: string;
  role: UserRole;
  profileImageUrl?: string;
  profile_image_url?: string;
  savedAddresses?: Address[];
  saved_addresses?: Address[];
  createdAt?: string;
  created_at?: string;
}

export interface Category {
  id: string;
  name: string;
  imageUrl?: string;
  image_url: string;
  sortOrder?: number;
  sort_order?: number;
  productCount?: number;
  product_count?: number;
}

export interface Brand {
  id: string;
  name: string;
  imageUrl?: string;
  image_url: string;
  categoryId?: string;
  category_id?: string;
}

export interface Shop {
  id: string;
  name: string;
  logoUrl?: string;
  logo_url?: string;
  coverImageUrl?: string;
  cover_image_url?: string;
  rating: number;
  reviewCount?: number;
  review_count?: number;
  address: string;
  distanceKm?: number;
  distance_km?: number;
  isOpen?: boolean;
  is_open?: boolean;
  categories: string[];
  phone?: string;
}

export interface Product {
  id: string;
  title: string;
  description: string;
  price: number;
  originalPrice?: number;
  original_price?: number;
  categoryId?: string;
  category_id: string;
  categoryName?: string;
  category_name?: string;
  shopId?: string;
  shop_id?: string;
  shopName?: string;
  shop_name?: string;
  brandId?: string;
  brand_id?: string;
  brandName?: string;
  brand_name?: string;
  imageUrls?: string[];
  image_urls: string[];
  specifications: Record<string, any>;
  rating: number;
  totalReviews?: number;
  total_reviews: number;
  stockQuantity?: number;
  stock_quantity: number;
  unit: string;
  isActive?: boolean;
  is_active?: boolean;
  createdAt?: string;
  created_at?: string;
}

export interface Banner {
  id: string;
  title: string;
  subtitle?: string;
  imageUrl?: string;
  image_url: string;
  targetCategory?: string;
  target_category?: string;
  discountText?: string;
  discount_text?: string;
  isFeatured?: boolean;
  is_featured?: boolean;
}

export interface CartItem {
  id: string;
  productId?: string;
  product_id?: string;
  title: string;
  price: number;
  quantity: number;
  imageUrl?: string;
  image_url?: string;
  unit: string;
  shopId?: string;
  shop_id?: string;
  subtotal?: number;
}

export interface CartSummary {
  items: CartItem[];
  subtotal: number;
  tax: number;
  deliveryFee?: number;
  delivery_fee?: number;
  discount: number;
  total: number;
  totalCount?: number;
  total_count: number;
}

export type OrderStatus =
  | "pending"
  | "confirmed"
  | "processing"
  | "dispatched"
  | "out_for_delivery"
  | "delivered"
  | "cancelled";

export type PaymentMethod = "razorpay" | "cod" | "upi" | "netbanking" | "card" | "credit";
export type PaymentStatus = "pending" | "paid" | "failed" | "refunded";

export interface OrderItem {
  id: string;
  productId?: string;
  product_id?: string;
  title: string;
  price: number;
  quantity: number;
  unit: string;
  imageUrl?: string;
  image_url?: string;
}

export interface Order {
  id: string;
  orderNumber?: string;
  order_number: string;
  userId?: string;
  user_id?: string;
  items: OrderItem[];
  subtotal: number;
  tax: number;
  deliveryFee?: number;
  delivery_fee?: number;
  totalAmount?: number;
  total_amount: number;
  status: OrderStatus;
  paymentMethod?: PaymentMethod;
  payment_method?: PaymentMethod;
  paymentStatus?: PaymentStatus;
  payment_status?: PaymentStatus;
  razorpayOrderId?: string;
  razorpay_order_id?: string;
  deliveryAddress?: Address | any;
  delivery_address: Address | any;
  estimatedDelivery?: string;
  estimated_delivery?: string;
  createdAt?: string;
  created_at: string;
  updatedAt?: string;
  updated_at?: string;
}

export interface QuoteItem {
  productId?: string;
  product_id?: string;
  title: string;
  quantity: number;
  unit: string;
  category?: string;
  notes?: string;
}

export interface QuoteRequest {
  id: string;
  quoteNumber?: string;
  quote_number: string;
  customerName?: string;
  customer_name?: string;
  email: string;
  phone: string;
  projectName?: string;
  project_name?: string;
  deliveryPincode?: string;
  delivery_pincode?: string;
  items: any[];
  estimatedTotal?: number;
  estimated_total?: number;
  status: string;
  createdAt?: string;
  created_at?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  meta?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
