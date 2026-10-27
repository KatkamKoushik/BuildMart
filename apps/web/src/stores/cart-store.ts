import { create } from "zustand";
import { api } from "@/lib/api";
import type { CartItem, CartSummary, Product } from "@buildmart/shared";

interface CartState {
  items: CartItem[];
  subtotal: number;
  tax: number;
  deliveryFee: number;
  total: number;
  totalCount: number;
  isOpen: boolean;
  isLoading: boolean;
  fetchCart: () => Promise<void>;
  addItem: (product: Product, quantity?: number) => Promise<void>;
  updateQuantity: (itemId: string, quantity: number) => Promise<void>;
  removeItem: (itemId: string) => Promise<void>;
  clearCart: () => Promise<void>;
  setIsOpen: (isOpen: boolean) => void;
  toggleCart: () => void;
}

export const useCartStore = create<CartState>((set, get) => ({
  items: [],
  subtotal: 0,
  tax: 0,
  deliveryFee: 0,
  total: 0,
  totalCount: 0,
  isOpen: false,
  isLoading: false,

  fetchCart: async () => {
    try {
      set({ isLoading: true });
      const summary = await api.getCart();
      set({
        items: summary.items,
        subtotal: summary.subtotal,
        tax: summary.tax,
        deliveryFee: summary.delivery_fee ?? summary.deliveryFee ?? 0,
        total: summary.total,
        totalCount: summary.total_count ?? summary.totalCount ?? 0,
        isLoading: false,
      });
    } catch (e) {
      set({ isLoading: false });
    }
  },

  addItem: async (product: Product, quantity: number = 1) => {
    try {
      set({ isLoading: true });
      const summary = await api.addToCart(product.id, quantity);
      set({
        items: summary.items,
        subtotal: summary.subtotal,
        tax: summary.tax,
        deliveryFee: summary.delivery_fee ?? summary.deliveryFee ?? 0,
        total: summary.total,
        totalCount: summary.total_count ?? summary.totalCount ?? 0,
        isLoading: false,
        isOpen: true,
      });
    } catch (e) {
      set({ isLoading: false });
    }
  },

  updateQuantity: async (itemId: string, quantity: number) => {
    try {
      set({ isLoading: true });
      const summary = await api.updateCartItem(itemId, quantity);
      set({
        items: summary.items,
        subtotal: summary.subtotal,
        tax: summary.tax,
        deliveryFee: summary.delivery_fee ?? summary.deliveryFee ?? 0,
        total: summary.total,
        totalCount: summary.total_count ?? summary.totalCount ?? 0,
        isLoading: false,
      });
    } catch (e) {
      set({ isLoading: false });
    }
  },

  removeItem: async (itemId: string) => {
    try {
      set({ isLoading: true });
      const summary = await api.removeCartItem(itemId);
      set({
        items: summary.items,
        subtotal: summary.subtotal,
        tax: summary.tax,
        deliveryFee: summary.delivery_fee ?? summary.deliveryFee ?? 0,
        total: summary.total,
        totalCount: summary.total_count ?? summary.totalCount ?? 0,
        isLoading: false,
      });
    } catch (e) {
      set({ isLoading: false });
    }
  },

  clearCart: async () => {
    try {
      await api.clearCart();
      set({
        items: [],
        subtotal: 0,
        tax: 0,
        deliveryFee: 0,
        total: 0,
        totalCount: 0,
      });
    } catch (e) {}
  },

  setIsOpen: (isOpen: boolean) => set({ isOpen }),
  toggleCart: () => set((state) => ({ isOpen: !state.isOpen })),
}));
