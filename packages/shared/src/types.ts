export type UserRole = "buyer" | "vendor" | "admin";

export interface Address {
  id: string;
  fullName: string;
  addressLine1: string;
  addressLine2?: string;
  city: string;
  state: string;
  postalCode: string;
  phone: string;
  isDefault?: boolean;
}

export interface User {
  id: string;
  firebaseUid?: string;
  name: string;
  email: string;
  phone?: string;
  role: UserRole;
  profileImageUrl?: string;
  savedAddresses: Address[];
  createdAt: string;
}

export interface Category {
  id: string;
  name: string;
  imageUrl: string;
  productCount?: number;
}

export interface Brand {
  id: string;
  name: string;
  imageUrl: string;
  categoryId?: string;
}

export interface Shop {
  id: string;
  name: string;
  logoUrl?: string;
  coverImageUrl?: string;
  rating: number;
  reviewCount: number;
  address: string;
  distanceKm?: number;
  isOpen: boolean;
  categories: string[];
  phone?: string;
}

export interface Product {
  id: string;
  title: string;
  description: string;
  price: number;
  originalPrice?: number;
  categoryId: string;
  categoryName?: string;
  shopId?: string;
  shopName?: string;
  brandId?: string;
  brandName?: string;
  imageUrls: string[];
  specifications: Record<string, string>;
  rating: number;
  totalReviews: number;
  stockQuantity: number;
  unit: string;
  isActive: boolean;
  createdAt: string;
}

export interface Banner {
  id: string;
  title: string;
  subtitle: string;
  imageUrl: string;
  targetCategory?: string;
  discountText?: string;
  isFeatured?: boolean;
}

export interface CartItem {
  id: string;
  productId: string;
  title: string;
  price: number;
  quantity: number;
  imageUrl: string;
  unit: string;
  shopId?: string;
}

export interface CartSummary {
  items: CartItem[];
  subtotal: number;
  tax: number;
  deliveryFee: number;
  discount: number;
  total: number;
  totalCount: number;
}

export type OrderStatus =
  | "pending"
  | "confirmed"
  | "processing"
  | "dispatched"
  | "out_for_delivery"
  | "delivered"
  | "cancelled";

export type PaymentMethod = "razorpay" | "cod" | "upi" | "netbanking" | "card";
export type PaymentStatus = "pending" | "paid" | "failed" | "refunded";

export interface OrderItem {
  id: string;
  productId: string;
  title: string;
  price: number;
  quantity: number;
  unit: string;
  imageUrl: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  userId: string;
  items: OrderItem[];
  subtotal: number;
  tax: number;
  deliveryFee: number;
  totalAmount: number;
  status: OrderStatus;
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  razorpayOrderId?: string;
  razorpayPaymentId?: string;
  deliveryAddress: Address;
  estimatedDelivery?: string;
  createdAt: string;
  updatedAt: string;
}

export interface QuoteItem {
  productId?: string;
  title: string;
  quantity: number;
  unit: string;
  category?: string;
  notes?: string;
}

export interface QuoteRequest {
  id: string;
  quoteNumber: string;
  customerName: string;
  email: string;
  phone: string;
  projectName?: string;
  deliveryPincode: string;
  items: QuoteItem[];
  estimatedTotal?: number;
  status: "draft" | "submitted" | "approved" | "rejected";
  createdAt: string;
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
