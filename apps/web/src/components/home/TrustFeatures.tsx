import React from "react";
import Link from "next/link";
import { Factory, FileCheck2, Truck, ShieldAlert, ArrowRight } from "lucide-react";

export const TrustFeatures: React.FC = () => {
  return (
    <section className="bg-buildmart-navy-light/90 border border-slate-800 rounded-3xl p-6 sm:p-10 text-white relative overflow-hidden">
      {/* Decorative accent */}
      <div className="absolute top-0 right-0 w-96 h-96 bg-amber-500/10 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-7xl mx-auto space-y-8 relative z-10">
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
          <div className="space-y-2">
            <span className="text-amber-400 font-bold text-xs uppercase tracking-wider">
              ENTERPRISE ADVANTAGE
            </span>
            <h2 className="font-display font-extrabold text-2xl sm:text-3xl text-white">
              Why 4,500+ Contractors Build with BuildMart
            </h2>
            <p className="text-slate-300 text-sm max-w-xl">
              Eliminate middlemen markups, avoid counterfeit materials, and ensure guaranteed project timeline compliance.
            </p>
          </div>

          <Link
            href="/quotes"
            className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-400 text-buildmart-navy font-bold px-6 py-3 rounded-xl text-sm transition self-start md:self-auto"
          >
            <span>Contractor Bulk Desk</span>
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-3 hover:bg-white/10 transition">
            <div className="w-12 h-12 rounded-xl bg-amber-400/20 text-amber-400 flex items-center justify-center">
              <Factory className="w-6 h-6" />
            </div>
            <h3 className="font-bold text-base text-white">Primary Mill Sourcing</h3>
            <p className="text-xs text-slate-300 leading-relaxed">
              Cement and steel sourced straight from UltraTech, Tata Tiscon, Ambuja, and KCP plants with valid Mill Test Certificates (MTC).
            </p>
          </div>

          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-3 hover:bg-white/10 transition">
            <div className="w-12 h-12 rounded-xl bg-amber-400/20 text-amber-400 flex items-center justify-center">
              <FileCheck2 className="w-6 h-6" />
            </div>
            <h3 className="font-bold text-base text-white">Instant Project Quotations</h3>
            <p className="text-xs text-slate-300 leading-relaxed">
              Upload BOM specifications or select items to generate an official branded PDF quotation for client approval in seconds.
            </p>
          </div>

          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-3 hover:bg-white/10 transition">
            <div className="w-12 h-12 rounded-xl bg-amber-400/20 text-amber-400 flex items-center justify-center">
              <Truck className="w-6 h-6" />
            </div>
            <h3 className="font-bold text-base text-white">GPS Monitored Fleet</h3>
            <p className="text-xs text-slate-300 leading-relaxed">
              Live tracking from warehouse dispatch to job site gate with dedicated hydraulic crane unloading on request.
            </p>
          </div>

          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-3 hover:bg-white/10 transition">
            <div className="w-12 h-12 rounded-xl bg-amber-400/20 text-amber-400 flex items-center justify-center">
              <ShieldAlert className="w-6 h-6" />
            </div>
            <h3 className="font-bold text-base text-white">Input Tax Credit (GST)</h3>
            <p className="text-xs text-slate-300 leading-relaxed">
              100% legitimate GST e-invoices with HSN code accuracy and full Input Tax Credit eligibility for developer accounting.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};
