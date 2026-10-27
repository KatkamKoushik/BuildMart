"use client";

import React, { useState, useEffect, Suspense } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { api } from "@/lib/api";
import { formatCurrency } from "@/lib/utils";
import type { Order } from "@buildmart/shared";
import {
  Package,
  Truck,
  CheckCircle2,
  Calendar,
  MapPin,
  XCircle,
} from "lucide-react";

export const dynamic = "force-dynamic";

function OrdersContent() {
  const searchParams = useSearchParams();
  const newlyPlacedOrderNumber = searchParams?.get("placed");

  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [cancelLoading, setCancelLoading] = useState<string | null>(null);

  const fetchOrders = async () => {
    try {
      const data = await api.getOrders();
      setOrders(data);
    } catch (e) {
      console.error("Failed to load orders:", e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  const handleCancelOrder = async (orderId: string) => {
    if (!confirm("Are you sure you want to cancel this order?")) return;
    try {
      setCancelLoading(orderId);
      await api.cancelOrder(orderId);
      await fetchOrders();
    } catch (e: any) {
      alert(e.message || "Could not cancel order");
    } finally {
      setCancelLoading(null);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "delivered":
        return "bg-emerald-100 text-emerald-800 border-emerald-300";
      case "dispatched":
      case "out_for_delivery":
        return "bg-blue-100 text-blue-800 border-blue-300";
      case "processing":
        return "bg-purple-100 text-purple-800 border-purple-300";
      case "cancelled":
        return "bg-red-100 text-red-800 border-red-300";
      default:
        return "bg-amber-100 text-amber-800 border-amber-300";
    }
  };

  return (
    <div className="space-y-8 max-w-5xl mx-auto">
      {/* Header */}
      <div>
        <h1 className="font-display font-black text-2xl sm:text-3xl text-slate-900">
          Your Material Orders
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Real-time tracking from warehouse dispatch to construction site gate
        </p>
      </div>

      {/* Confirmation Alert if just placed */}
      {newlyPlacedOrderNumber && (
        <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 flex items-center gap-3">
          <CheckCircle2 className="w-6 h-6 text-emerald-600 flex-shrink-0" />
          <div className="text-xs sm:text-sm text-emerald-900">
            <strong>Order Placed Successfully!</strong> Reference:{" "}
            <span className="font-mono font-bold">{newlyPlacedOrderNumber}</span>. Dispatch logistics
            have been assigned.
          </div>
        </div>
      )}

      {loading ? (
        <div className="text-center py-20 text-slate-400">Loading order records...</div>
      ) : orders.length === 0 ? (
        <div className="text-center py-24 glass-card rounded-3xl p-8 space-y-4 max-w-md mx-auto">
          <div className="w-16 h-16 mx-auto rounded-full bg-slate-100 flex items-center justify-center text-slate-400">
            <Package className="w-8 h-8" />
          </div>
          <h2 className="font-bold text-slate-800 text-lg">No Orders Found</h2>
          <p className="text-xs text-slate-500">
            You haven&apos;t placed any material orders yet. Explore our factory-direct prices to start building.
          </p>
          <Link
            href="/products"
            className="inline-block bg-amber-500 hover:bg-amber-600 text-buildmart-navy font-bold px-6 py-2.5 rounded-xl text-xs transition"
          >
            Browse Products
          </Link>
        </div>
      ) : (
        <div className="space-y-6">
          {orders.map((ord) => {
            const steps = ["confirmed", "processing", "dispatched", "delivered"];
            const currentStepIdx = steps.indexOf(ord.status);

            return (
              <div
                key={ord.id}
                className="glass-card rounded-2xl p-6 space-y-5 hover:border-slate-300 transition"
              >
                {/* Top Strip */}
                <div className="flex flex-wrap items-center justify-between gap-3 border-b border-slate-100 pb-4">
                  <div className="flex items-center gap-3">
                    <span className="font-mono font-bold text-slate-900 text-sm">
                      {ord.order_number}
                    </span>
                    <span
                      className={`text-[10px] font-bold uppercase px-2.5 py-0.5 rounded-full border ${getStatusColor(
                        ord.status
                      )}`}
                    >
                      {ord.status.replace("_", " ")}
                    </span>
                  </div>

                  <div className="flex items-center gap-4 text-xs text-slate-500">
                    <span className="flex items-center gap-1">
                      <Calendar className="w-3.5 h-3.5" />
                      {new Date(ord.created_at).toLocaleDateString("en-IN", {
                        day: "numeric",
                        month: "short",
                        year: "numeric",
                      })}
                    </span>
                    <span className="font-bold text-slate-900 text-sm">
                      {formatCurrency(ord.total_amount)}
                    </span>
                  </div>
                </div>

                {/* Tracking Progress Bar */}
                {ord.status !== "cancelled" && (
                  <div className="py-2">
                    <div className="relative flex justify-between items-center text-center">
                      <div className="absolute top-1/2 left-0 right-0 h-1 bg-slate-200 -translate-y-1/2 z-0" />
                      {steps.map((st, idx) => {
                        const isDone = currentStepIdx >= idx;
                        return (
                          <div key={st} className="relative z-10 flex flex-col items-center">
                            <div
                              className={`w-7 h-7 rounded-full flex items-center justify-center font-bold text-xs transition ${
                                isDone
                                  ? "bg-amber-500 text-buildmart-navy ring-4 ring-amber-100"
                                  : "bg-slate-200 text-slate-500"
                              }`}
                            >
                              {isDone ? <CheckCircle2 className="w-4 h-4" /> : idx + 1}
                            </div>
                            <span className="text-[10px] font-semibold text-slate-600 mt-1 capitalize">
                              {st}
                            </span>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                )}

                {/* Items & Address */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2 text-xs">
                  {/* Items */}
                  <div className="space-y-2 bg-slate-50 p-3.5 rounded-xl border border-slate-100">
                    <span className="font-bold text-slate-700 block text-[11px] uppercase tracking-wider">
                      Ordered Materials
                    </span>
                    <ul className="space-y-1.5">
                      {ord.items && ord.items.length > 0 ? (
                        ord.items.map((item, idx) => (
                          <li key={idx} className="flex justify-between text-slate-800">
                            <span className="line-clamp-1">{item.title}</span>
                            <span className="font-semibold text-slate-900 whitespace-nowrap ml-2">
                              {item.quantity} × {formatCurrency(item.price)}
                            </span>
                          </li>
                        ))
                      ) : (
                        <li className="text-slate-500">Materials package</li>
                      )}
                    </ul>
                  </div>

                  {/* Destination */}
                  <div className="space-y-2 bg-slate-50 p-3.5 rounded-xl border border-slate-100">
                    <span className="font-bold text-slate-700 block text-[11px] uppercase tracking-wider flex items-center gap-1">
                      <MapPin className="w-3.5 h-3.5 text-amber-500" />
                      <span>Delivery Site</span>
                    </span>
                    <div className="text-slate-600 space-y-0.5">
                      <p className="font-semibold text-slate-900">{ord.delivery_address?.fullName}</p>
                      <p>{ord.delivery_address?.addressLine1}</p>
                      <p>
                        {ord.delivery_address?.city}, {ord.delivery_address?.state} -{" "}
                        {ord.delivery_address?.postalCode}
                      </p>
                      <p className="text-slate-500">Contact: {ord.delivery_address?.phone}</p>
                    </div>
                  </div>
                </div>

                {/* Cancel Action if pending/confirmed */}
                {["confirmed", "pending"].includes(ord.status) && (
                  <div className="flex justify-end pt-2">
                    <button
                      onClick={() => handleCancelOrder(ord.id)}
                      disabled={cancelLoading === ord.id}
                      className="text-xs text-red-600 hover:text-red-700 font-semibold flex items-center gap-1 hover:bg-red-50 px-3 py-1.5 rounded-lg transition"
                    >
                      <XCircle className="w-3.5 h-3.5" />
                      <span>{cancelLoading === ord.id ? "Cancelling..." : "Cancel Order"}</span>
                    </button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

export default function OrdersPage() {
  return (
    <Suspense fallback={<div className="text-center py-20 text-slate-400">Loading orders...</div>}>
      <OrdersContent />
    </Suspense>
  );
}
