import { z } from "zod";

export const AddressSchema = z.object({
  id: z.string().optional(),
  fullName: z.string().min(2, "Full name must be at least 2 characters"),
  addressLine1: z.string().min(5, "Address must be at least 5 characters"),
  addressLine2: z.string().optional(),
  city: z.string().min(2, "City is required"),
  state: z.string().min(2, "State is required"),
  postalCode: z.string().regex(/^\d{6}$/, "Must be a valid 6-digit postal code"),
  phone: z.string().regex(/^[6-9]\d{9}$/, "Must be a valid 10-digit mobile number"),
  isDefault: z.boolean().optional().default(false),
});

export const CartItemSchema = z.object({
  productId: z.string().min(1, "Product ID is required"),
  quantity: z.number().int().min(1, "Quantity must be at least 1").max(1000, "Quantity exceeds limit"),
});

export const CheckoutRequestSchema = z.object({
  deliveryAddress: AddressSchema,
  paymentMethod: z.enum(["razorpay", "cod", "upi", "netbanking", "card"]),
  items: z.array(
    z.object({
      productId: z.string(),
      quantity: z.number().int().min(1),
    })
  ).min(1, "Cart cannot be empty"),
  deliveryNotes: z.string().max(500).optional(),
});

export const PaymentVerificationSchema = z.object({
  razorpayOrderId: z.string().min(1, "Order ID is required"),
  razorpayPaymentId: z.string().min(1, "Payment ID is required"),
  razorpaySignature: z.string().min(1, "Signature is required"),
});

export const QuoteRequestSchema = z.object({
  customerName: z.string().min(2, "Name required"),
  email: z.string().email("Valid email required"),
  phone: z.string().regex(/^[6-9]\d{9}$/, "Valid 10-digit phone required"),
  projectName: z.string().optional(),
  deliveryPincode: z.string().regex(/^\d{6}$/, "Valid 6-digit pincode required"),
  items: z.array(
    z.object({
      title: z.string().min(1, "Item name required"),
      quantity: z.number().min(1, "Quantity must be at least 1"),
      unit: z.string().default("units"),
      category: z.string().optional(),
      notes: z.string().optional(),
    })
  ).min(1, "At least one item is required for a quote"),
});

export type AddressInput = z.infer<typeof AddressSchema>;
export type CartItemInput = z.infer<typeof CartItemSchema>;
export type CheckoutRequestInput = z.infer<typeof CheckoutRequestSchema>;
export type PaymentVerificationInput = z.infer<typeof PaymentVerificationSchema>;
export type QuoteRequestInput = z.infer<typeof QuoteRequestSchema>;
