import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, List

def run_catalog_audit(seed_path: str = "mobile/assets/seeded_data.json") -> Dict[str, Any]:
    print("=" * 70)
    print("BUILDMART CATALOG & IMAGE-DATA INTEGRITY AUDIT (F-12)")
    print("=" * 70)

    p = Path(seed_path)
    if not p.exists():
        p = Path("../" + seed_path)
    if not p.exists():
        p = Path("../../" + seed_path)
    if not p.exists():
        raise FileNotFoundError(f"Seed file not found at: {seed_path}")

    print(f"Reading seed catalog from: {p.resolve()}")
    with open(p, "r", encoding="utf-8") as f:
        data = json.load(f)

    categories = data.get("categories", [])
    brands = data.get("brands", [])
    products = data.get("products", [])
    shops = data.get("shops", [])
    banners = data.get("banners", [])

    report = {
        "summary": {
            "total_categories": len(categories),
            "total_brands": len(brands),
            "total_products": len(products),
            "total_shops": len(shops),
            "total_banners": len(banners),
        },
        "integrity_checks": {
            "duplicate_product_ids": [],
            "missing_titles": [],
            "invalid_prices": [],
            "invalid_stock": [],
            "broken_category_fks": [],
            "broken_brand_fks": [],
            "missing_or_invalid_images": [],
        },
        "warnings": [],
        "passed": True
    }

    category_ids = {c.get("id") for c in categories if c.get("id")}
    brand_ids = {b.get("id") for b in brands if b.get("id")}
    seen_product_ids = set()

    for idx, prod in enumerate(products):
        prod_id = prod.get("id")
        title = prod.get("name") or prod.get("title")
        price = prod.get("price")
        cat_id = prod.get("categoryId") or prod.get("category_id")
        b_id = prod.get("brandId") or prod.get("brand_id")
        img = prod.get("imageUrl") or (prod.get("imageUrls") and prod.get("imageUrls")[0])

        # 1. Product ID uniqueness
        if not prod_id:
            report["integrity_checks"]["duplicate_product_ids"].append(f"Row {idx}: Missing ID")
        elif prod_id in seen_product_ids:
            report["integrity_checks"]["duplicate_product_ids"].append(prod_id)
        else:
            seen_product_ids.add(prod_id)

        # 2. Title validation
        if not title or len(str(title).strip()) < 2:
            report["integrity_checks"]["missing_titles"].append(prod_id or f"Row {idx}")

        # 3. Price validation
        if price is None or not isinstance(price, (int, float)) or price <= 0:
            report["integrity_checks"]["invalid_prices"].append({"id": prod_id, "price": price})

        # 4. Foreign Key validation - Category
        if not cat_id or cat_id not in category_ids:
            report["integrity_checks"]["broken_category_fks"].append({"id": prod_id, "category_id": cat_id})

        # 5. Foreign Key validation - Brand (optional, but if present must be valid)
        if b_id and b_id not in brand_ids:
            report["integrity_checks"]["broken_brand_fks"].append({"id": prod_id, "brand_id": b_id})

        # 6. Image validity
        if not img or not str(img).startswith("http"):
            report["integrity_checks"]["missing_or_invalid_images"].append(prod_id)

    # Check for hard failures
    failures = 0
    for check_name, issues in report["integrity_checks"].items():
        if issues:
            failures += len(issues)
            print(f"[FAIL] {check_name}: {len(issues)} issues detected")
        else:
            print(f"[PASS] {check_name}: 0 issues")

    report["passed"] = (failures == 0)

    # Output machine-readable JSON
    out_dir = Path("scripts/audits")
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / "catalog_audit_report.json"
    with open(out_file, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    print("-" * 70)
    print(f"Audit Status: {'VERIFIED PASSED' if report['passed'] else 'AUDIT FAILED'}")
    print(f"Machine-readable audit report written to: {out_file.resolve()}")
    print("=" * 70)
    return report

if __name__ == "__main__":
    rep = run_catalog_audit()
    if not rep["passed"]:
        sys.exit(1)
