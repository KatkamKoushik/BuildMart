import test from "node:test";
import assert from "node:assert/strict";
import {
  AddressSchema,
  CartItemSchema,
  CheckoutRequestSchema,
  PaymentVerificationSchema,
  QuoteRequestSchema
} from "../src/schemas.ts";

test("AddressSchema validates correct postal codes and Indian mobile numbers", () => {
  const validAddress = {
    fullName: "John Builder",
    addressLine1: "Plot 42, Industrial Area",
    city: "Hyderabad",
    state: "Telangana",
    postalCode: "500081",
    phone: "9876543210",
  };
  const parsed = AddressSchema.parse(validAddress);
  assert.equal(parsed.postalCode, "500081");
  assert.equal(parsed.phone, "9876543210");
  assert.equal(parsed.isDefault, false);
});

test("AddressSchema rejects invalid postal codes and invalid phone formats", () => {
  assert.throws(() => {
    AddressSchema.parse({
      fullName: "John",
      addressLine1: "Plot 42",
      city: "Hyd",
      state: "TS",
      postalCode: "123", // invalid length
      phone: "9876543210",
    });
  });

  assert.throws(() => {
    AddressSchema.parse({
      fullName: "John",
      addressLine1: "Plot 42",
      city: "Hyd",
      state: "TS",
      postalCode: "500081",
      phone: "1234567890", // invalid starting digit
    });
  });
});

test("CartItemSchema enforces positive integer quantities within bounds", () => {
  const validItem = CartItemSchema.parse({ productId: "prod_1", quantity: 5 });
  assert.equal(validItem.quantity, 5);

  assert.throws(() => CartItemSchema.parse({ productId: "prod_1", quantity: 0 }));
  assert.throws(() => CartItemSchema.parse({ productId: "prod_1", quantity: -2 }));
  assert.throws(() => CartItemSchema.parse({ productId: "prod_1", quantity: 1001 }));
});

test("PaymentVerificationSchema validates required Razorpay credentials", () => {
  const validPayment = {
    razorpayOrderId: "order_98765",
    razorpayPaymentId: "pay_12345",
    razorpaySignature: "sig_abcdef123456",
  };
  const result = PaymentVerificationSchema.parse(validPayment);
  assert.equal(result.razorpayOrderId, "order_98765");

  assert.throws(() => {
    PaymentVerificationSchema.parse({
      razorpayOrderId: "",
      razorpayPaymentId: "pay_12345",
      razorpaySignature: "sig_abcdef123456",
    });
  });
});

test("QuoteRequestSchema requires customer details and at least one item", () => {
  const validQuote = {
    customerName: "Apex Infrastructure",
    email: "procurement@apex.com",
    phone: "9123456780",
    deliveryPincode: "500032",
    items: [
      {
        title: "OPC 53 Cement Bags",
        quantity: 100,
        unit: "bags",
      },
    ],
  };
  const result = QuoteRequestSchema.parse(validQuote);
  assert.equal(result.items.length, 1);
  assert.equal(result.deliveryPincode, "500032");

  assert.throws(() => {
    QuoteRequestSchema.parse({
      ...validQuote,
      items: [], // empty items
    });
  });
});

