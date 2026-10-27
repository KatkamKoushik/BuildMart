# BuildMart Maintenance, Data Migration & Audit Tooling 🛠️

This directory contains offline utility, data cleaning, and audit scripts used during the initial development, catalog curation, and image synchronization of BuildMart.

> **Note**: These scripts are **NOT** part of the application runtime and are never included in production builds. They are developer/maintainer utilities intended for offline data curation and catalog auditing.

---

## 📁 Directory Structure

```text
scripts/
├── audits/        # Verification, consistency audits, and analysis reports
├── migrations/    # Data sanitization, price normalization, and brand correction
├── upload/        # Cloud asset uploaders and Cloudinary catalog synchronizers
└── scratch/       # Exploratory developer scratch scripts for data inspection
```

---

## 🔍 `scripts/audits/`
Scripts and reports that inspect and verify product listings, image links, and brand uniformity:

| File | Description |
| :--- | :--- |
| `audit.py` | Full catalog scanner verifying product fields, pricing integrity, and asset availability. |
| `check_categories.py` | Validates category name consistency against supported application taxonomies. |
| `find_extra_images.py` | Identifies orphan image files in local asset directories not referenced in `seeded_data.json`. |
| `remove_duplicate_images.py` | Finds duplicate image hashes and prunes redundant asset entries. |
| `audit.txt` / `audit_output.txt` / `audit_report.txt` | Historical log outputs generated from catalog validation runs. |
| `price_audit.txt` | Pricing discrepancy report identifying zero, negative, or anomalous prices. |

---

## 🔄 `scripts/migrations/`
One-time and batch migration scripts to normalize seed data in `assets/seeded_data.json`:

| File | Description |
| :--- | :--- |
| `fix_data.py` | General schema normalization across all catalog entries. |
| `fix_pricing.py` / `scratch_fix_prices.py` | Standardizes product currency, unit pricing, and discounts. |
| `fix_brands.py` / `fix_brands_properly.py` / `clean_dummy_brands.py` | Standardizes brand identifiers and removes placeholder manufacturer names. |
| `fix_cement_names.py` / `fix_paints_names.py` | Fixes naming conventions for cement bags and paint volume metrics. |
| `fix_berger_upload_asian.py` | Replaces mislabeled paint brand assets with verified manufacturer imagery. |
| `deduplicate_products.py` | Merges duplicate SKU items sharing identical titles and specifications. |
| `restore_missing_products.py` / `restore_from_audit.py` / `restore_images.py` | Re-seeds products that were mistakenly pruned during aggressive deduplication passes. |
| `seed_doors_glass.py` | Generates initial product entries for the Doors & Glass catalog category. |
| `unify_categories.py` | Consolidates legacy category aliases into standardized system categories. |

---

## ☁️ `scripts/upload/`
Utilities for synchronizing catalog imagery with Cloudinary:

| File | Description |
| :--- | :--- |
| `fetch_cloudinary.py` | Verifies existence and CDN accessibility of remote Cloudinary assets. |
| `upload_new_folders.py` | Recursively uploads newly added local category assets to designated Cloudinary folders. |
| `upload_products.py` | Uploads product images and updates remote URLs in `assets/seeded_data.json`. |

> **Prerequisites for upload scripts**: Require `python-dotenv` and `cloudinary` Python packages. You must provide `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, and `CLOUDINARY_API_SECRET` in a local `.env` file before executing upload tasks.
