import React from "react";
import Link from "next/link";
import { ShieldCheck, Truck, Clock, RefreshCw, Award, Mail, Phone, MapPin } from "lucide-react";

export const Footer: React.FC = () => {
  return (
    <footer className="bg-buildmart-navy text-slate-300 mt-20 border-t border-slate-800">
      {/* Trust Badges Bar */}
      <div className="border-b border-slate-800 py-8 px-4 sm:px-6">
        <div className="max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-6 text-center sm:text-left">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-amber-500/10 text-amber-400 rounded-xl">
              <ShieldCheck className="w-6 h-6" />
            </div>
            <div>
              <h4 className="font-semibold text-white text-sm">100% Genuine Brands</h4>
              <p className="text-xs text-slate-400">Direct factory sourcing</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="p-3 bg-amber-500/10 text-amber-400 rounded-xl">
              <Truck className="w-6 h-6" />
            </div>
            <div>
              <h4 className="font-semibold text-white text-sm">Site-Direct Delivery</h4>
              <p className="text-xs text-slate-400">Hydraulic unloading available</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="p-3 bg-amber-500/10 text-amber-400 rounded-xl">
              <Award className="w-6 h-6" />
            </div>
            <div>
              <h4 className="font-semibold text-white text-sm">GST Compliant Invoices</h4>
              <p className="text-xs text-slate-400">Input tax credit eligible</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="p-3 bg-amber-500/10 text-amber-400 rounded-xl">
              <Clock className="w-6 h-6" />
            </div>
            <div>
              <h4 className="font-semibold text-white text-sm">Rapid Dispatch</h4>
              <p className="text-xs text-slate-400">Within 24–48 hours</p>
            </div>
          </div>
        </div>
      </div>

      {/* Main Footer Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-12 grid grid-cols-1 md:grid-cols-5 gap-8">
        {/* Company Bio */}
        <div className="md:col-span-2 space-y-4">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-amber-500 flex items-center justify-center font-display font-black text-buildmart-navy text-base">
              BM
            </div>
            <span className="font-display font-black text-xl text-white">
              BUILD<span className="text-amber-400">MART</span>
            </span>
          </div>
          <p className="text-sm text-slate-400 leading-relaxed pr-6">
            BuildMart is India&apos;s high-velocity digital procurement platform for certified construction materials.
            Connecting contractors, builders, and individual developers directly with primary cement, steel, plumbing, and electrical manufacturers.
          </p>
          <div className="text-xs text-slate-400 space-y-1.5 pt-2">
            <p className="flex items-center gap-2">
              <MapPin className="w-4 h-4 text-amber-400" />
              Corporate Towers, Cyber Hills, Hitec City, Hyderabad 500081
            </p>
            <p className="flex items-center gap-2">
              <Phone className="w-4 h-4 text-amber-400" />
              +91 (040) 4889-2200 / 1800-233-8899
            </p>
            <p className="flex items-center gap-2">
              <Mail className="w-4 h-4 text-amber-400" />
              procurement@buildmart.in
            </p>
          </div>
        </div>

        {/* Categories */}
        <div className="space-y-3">
          <h4 className="font-semibold text-white text-sm uppercase tracking-wider">Top Categories</h4>
          <ul className="text-xs space-y-2 text-slate-400">
            <li><Link href="/products?category_id=cement" className="hover:text-amber-400 transition">OPC & PPC Cement</Link></li>
            <li><Link href="/products?category_id=steel" className="hover:text-amber-400 transition">Fe 550D TMT Steel</Link></li>
            <li><Link href="/products?category_id=bricks_blocks" className="hover:text-amber-400 transition">AAC Blocks & Red Bricks</Link></li>
            <li><Link href="/products?category_id=plumbing" className="hover:text-amber-400 transition">CPVC & SWR Pipes</Link></li>
            <li><Link href="/products?category_id=electricals" className="hover:text-amber-400 transition">Wires & Switchgear</Link></li>
            <li><Link href="/products?category_id=paints" className="hover:text-amber-400 transition">Wall Primers & Emulsions</Link></li>
          </ul>
        </div>

        {/* Services */}
        <div className="space-y-3">
          <h4 className="font-semibold text-white text-sm uppercase tracking-wider">Services</h4>
          <ul className="text-xs space-y-2 text-slate-400">
            <li><Link href="/quotes" className="hover:text-amber-400 transition">Bulk Project Quotation</Link></li>
            <li><Link href="/shops" className="hover:text-amber-400 transition">Verified Material Yards</Link></li>
            <li><Link href="/orders" className="hover:text-amber-400 transition">Real-time Fleet Tracking</Link></li>
            <li><a href="#credit" className="hover:text-amber-400 transition">Contractor 30-Day Credit</a></li>
            <li><a href="#quality" className="hover:text-amber-400 transition">Mill Test Certificates (MTC)</a></li>
          </ul>
        </div>

        {/* Legal & Security */}
        <div className="space-y-3">
          <h4 className="font-semibold text-white text-sm uppercase tracking-wider">Assurance & Trust</h4>
          <div className="space-y-2 text-xs text-slate-400">
            <p className="bg-slate-900 p-2.5 rounded-lg border border-slate-800">
              <strong className="text-amber-400 block mb-0.5">Payment Security</strong>
              128-bit SSL encrypted checkout via Razorpay, UPI & Netbanking.
            </p>
            <p className="bg-slate-900 p-2.5 rounded-lg border border-slate-800">
              <strong className="text-amber-400 block mb-0.5">ISO 9001:2015</strong>
              Standardized inspection at manufacturer dispatch terminals.
            </p>
          </div>
        </div>
      </div>

      {/* Copyright Strip */}
      <div className="border-t border-slate-800 py-6 text-center text-xs text-slate-500">
        <p>© {new Date().getFullYear()} BuildMart Technologies India Pvt. Ltd. All rights reserved.</p>
      </div>
    </footer>
  );
};
