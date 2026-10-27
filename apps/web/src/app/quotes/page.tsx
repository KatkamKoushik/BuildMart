"use client";

import React, { useState } from "react";
import { api } from "@/lib/api";
import {
  FileText,
  Plus,
  Trash2,
  Download,
  CheckCircle2,
  Building2,
  ShieldCheck,
  Send,
} from "lucide-react";

interface ItemRow {
  title: string;
  quantity: number;
  unit: string;
  notes?: string;
}

export default function QuotesPage() {
  const [customerName, setCustomerName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [projectName, setProjectName] = useState("");
  const [deliveryPincode, setDeliveryPincode] = useState("500081");

  const [items, setItems] = useState<ItemRow[]>([
    { title: "UltraTech Super Cement (50kg bags)", quantity: 250, unit: "bags" },
    { title: "Tata Tiscon 550D TMT Steel 12mm", quantity: 5, unit: "tonnes" },
  ]);

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submittedQuote, setSubmittedQuote] = useState<{
    id: string;
    quote_number: string;
  } | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleAddItem = () => {
    setItems([...items, { title: "", quantity: 1, unit: "units" }]);
  };

  const handleRemoveItem = (index: number) => {
    if (items.length <= 1) return;
    setItems(items.filter((_, i) => i !== index));
  };

  const handleItemChange = (index: number, field: keyof ItemRow, value: any) => {
    const updated = [...items];
    updated[index] = { ...updated[index], [field]: value };
    setItems(updated);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (items.some((i) => !i.title.trim())) {
      setError("Please ensure all item descriptions are filled.");
      return;
    }

    try {
      setIsSubmitting(true);
      setError(null);
      const res = await api.submitQuote({
        customer_name: customerName,
        email,
        phone,
        project_name: projectName,
        delivery_pincode: deliveryPincode,
        items,
      });
      setSubmittedQuote({ id: res.id, quote_number: res.quote_number });
    } catch (err: any) {
      setError(err.message || "Failed to submit quote request.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-8 max-w-4xl mx-auto">
      <div>
        <h1 className="font-display font-black text-2xl sm:text-3xl text-slate-900">
          Request Commercial Project Estimate (BOM)
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Submit your required bill of materials to receive direct plant wholesale quotes with an instant PDF estimate.
        </p>
      </div>

      {submittedQuote ? (
        <div className="glass-card rounded-3xl p-8 sm:p-12 text-center space-y-6">
          <div className="w-20 h-20 mx-auto rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center">
            <CheckCircle2 className="w-10 h-10" />
          </div>

          <div className="space-y-2">
            <h2 className="font-display font-black text-2xl text-slate-900">
              Quotation Generated Successfully!
            </h2>
            <p className="text-sm text-slate-600 max-w-md mx-auto">
              Your official estimate reference is{" "}
              <strong className="text-slate-900 font-mono">{submittedQuote.quote_number}</strong>.
              Our commercial project desk has been alerted for factory pricing alignment.
            </p>
          </div>

          <div className="pt-4 flex flex-wrap justify-center gap-4">
            <a
              href={api.getQuotePdfUrl(submittedQuote.id)}
              target="_blank"
              rel="noopener noreferrer"
              className="bg-amber-500 hover:bg-amber-600 text-buildmart-navy font-bold px-8 py-3.5 rounded-xl text-sm flex items-center gap-2 shadow-glow transition"
            >
              <Download className="w-4 h-4" />
              <span>Download Official PDF Quotation</span>
            </a>

            <button
              onClick={() => {
                setSubmittedQuote(null);
                setItems([{ title: "", quantity: 1, unit: "units" }]);
              }}
              className="bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold px-6 py-3.5 rounded-xl text-sm transition"
            >
              Submit Another Project
            </button>
          </div>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="space-y-8">
          {error && (
            <div className="p-4 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm">
              {error}
            </div>
          )}

          {/* Project & Contractor Info */}
          <div className="glass-card rounded-2xl p-6 space-y-4">
            <div className="flex items-center gap-2 font-bold text-slate-900 text-sm border-b border-slate-100 pb-2.5">
              <Building2 className="w-4 h-4 text-amber-500" />
              <span>Contractor & Project Details</span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div className="space-y-1">
                <label className="font-semibold text-slate-700">Contractor / Firm Name *</label>
                <input
                  type="text"
                  required
                  value={customerName}
                  onChange={(e) => setCustomerName(e.target.value)}
                  placeholder="e.g. Skyline Infrastructure Ltd."
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none"
                />
              </div>

              <div className="space-y-1">
                <label className="font-semibold text-slate-700">Project / Site Name</label>
                <input
                  type="text"
                  value={projectName}
                  onChange={(e) => setProjectName(e.target.value)}
                  placeholder="e.g. Horizon Heights Phase 1"
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none"
                />
              </div>

              <div className="space-y-1">
                <label className="font-semibold text-slate-700">Work Email *</label>
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="procurement@skyline.in"
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none"
                />
              </div>

              <div className="space-y-1">
                <label className="font-semibold text-slate-700">Mobile Phone *</label>
                <input
                  type="tel"
                  required
                  pattern="[0-9]{10}"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="9876543210"
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none"
                />
              </div>

              <div className="space-y-1 sm:col-span-2">
                <label className="font-semibold text-slate-700">Delivery Job Site Pincode *</label>
                <input
                  type="text"
                  required
                  pattern="[0-9]{6}"
                  value={deliveryPincode}
                  onChange={(e) => setDeliveryPincode(e.target.value)}
                  placeholder="500081"
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none"
                />
              </div>
            </div>
          </div>

          {/* Materials Bill of Materials */}
          <div className="glass-card rounded-2xl p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-2.5">
              <div className="flex items-center gap-2 font-bold text-slate-900 text-sm">
                <FileText className="w-4 h-4 text-amber-500" />
                <span>Required Materials (BOM)</span>
              </div>
              <button
                type="button"
                onClick={handleAddItem}
                className="flex items-center gap-1 text-xs font-bold text-amber-600 hover:text-amber-700 bg-amber-50 hover:bg-amber-100 px-3 py-1.5 rounded-lg transition"
              >
                <Plus className="w-3.5 h-3.5" />
                <span>Add Item Row</span>
              </button>
            </div>

            <div className="space-y-3">
              {items.map((item, index) => (
                <div
                  key={index}
                  className="grid grid-cols-12 gap-3 items-center bg-slate-50 p-3 rounded-xl border border-slate-200"
                >
                  <div className="col-span-12 sm:col-span-6">
                    <label className="text-[11px] font-semibold text-slate-600 block mb-1">
                      Material Title / Specification
                    </label>
                    <input
                      type="text"
                      required
                      value={item.title}
                      onChange={(e) => handleItemChange(index, "title", e.target.value)}
                      placeholder="e.g. OPC 53 Grade Cement or 16mm TMT Rods"
                      className="w-full border border-slate-300 rounded-lg p-2 text-xs focus:ring-2 focus:ring-amber-400 focus:outline-none bg-white"
                    />
                  </div>

                  <div className="col-span-6 sm:col-span-3">
                    <label className="text-[11px] font-semibold text-slate-600 block mb-1">
                      Quantity
                    </label>
                    <input
                      type="number"
                      min="1"
                      required
                      value={item.quantity}
                      onChange={(e) =>
                        handleItemChange(index, "quantity", parseFloat(e.target.value) || 1)
                      }
                      className="w-full border border-slate-300 rounded-lg p-2 text-xs focus:ring-2 focus:ring-amber-400 focus:outline-none bg-white"
                    />
                  </div>

                  <div className="col-span-5 sm:col-span-2">
                    <label className="text-[11px] font-semibold text-slate-600 block mb-1">
                      Unit
                    </label>
                    <select
                      value={item.unit}
                      onChange={(e) => handleItemChange(index, "unit", e.target.value)}
                      className="w-full border border-slate-300 rounded-lg p-2 text-xs focus:ring-2 focus:ring-amber-400 focus:outline-none bg-white"
                    >
                      <option value="bags">Bags (50kg)</option>
                      <option value="tonnes">Tonnes (MT)</option>
                      <option value="units">Units / Pcs</option>
                      <option value="sqft">Sq. Ft</option>
                      <option value="running_mtr">Running Mtr</option>
                    </select>
                  </div>

                  <div className="col-span-1 flex justify-center pt-5 sm:pt-4">
                    <button
                      type="button"
                      onClick={() => handleRemoveItem(index)}
                      disabled={items.length <= 1}
                      className="text-slate-400 hover:text-red-500 disabled:opacity-30 transition"
                      title="Delete item"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="flex items-center justify-between pt-2">
            <div className="flex items-center gap-2 text-xs text-slate-500">
              <ShieldCheck className="w-4 h-4 text-emerald-600" />
              <span>Plant Mill test certificates included with all quotations</span>
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="bg-amber-500 hover:bg-amber-600 text-buildmart-navy font-bold py-3.5 px-8 rounded-xl text-sm flex items-center gap-2 shadow-glow transition disabled:opacity-50"
            >
              <Send className="w-4 h-4" />
              <span>{isSubmitting ? "Generating PDF..." : "Generate Official Quote PDF"}</span>
            </button>
          </div>
        </form>
      )}
    </div>
  );
}
