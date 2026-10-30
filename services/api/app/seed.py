import asyncio
import json
from pathlib import Path

from app.core.security import get_or_create_default_user
from app.db.session import AsyncSessionLocal, Base, engine
from app.models.models import (
    Banner,
    Brand,
    Category,
    Product,
    Shop,
)
from sqlalchemy import select


async def seed_database(session_factory=None):
    target_engine = (
        session_factory.kw["bind"]
        if (session_factory and hasattr(session_factory, "kw") and "bind" in session_factory.kw)
        else engine
    )
    print("[Seed] Initializing database schema...")
    async with target_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Locate seeded_data.json
    possible_paths = [
        Path("mobile/assets/seeded_data.json"),
        Path("../../mobile/assets/seeded_data.json"),
        Path("assets/seeded_data.json"),
        Path("../assets/seeded_data.json"),
    ]
    seed_file = None
    for p in possible_paths:
        if p.exists():
            seed_file = p
            break

    if not seed_file:
        print(f"[Seed] Warning: seeded_data.json not found in {possible_paths}")
        return

    print(f"[Seed] Loading seed data from {seed_file}...")
    with open(seed_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    session_maker = session_factory or AsyncSessionLocal
    async with session_maker() as session:
        # 1. Create or get Default Users (Buyer, Admin, Seller)
        print("[Seed] Seeding default demo users...")
        await get_or_create_default_user(
            session, email="buyer@buildmart.dev", role="buyer", name="BuildMart Demo Buyer"
        )
        await get_or_create_default_user(
            session, email="admin@buildmart.dev", role="admin", name="BuildMart Super Admin"
        )
        await get_or_create_default_user(
            session, email="seller@buildmart.dev", role="seller", name="Sri Lakshmi Steels Manager"
        )

        # 2. Categories
        categories_data = data.get("categories", [])
        print(f"[Seed] Seeding {len(categories_data)} categories...")
        cat_ids = [cat.get("id") for cat in categories_data if cat.get("id")]
        existing_cat_ids = set()
        if cat_ids:
            res = await session.execute(select(Category.id).where(Category.id.in_(cat_ids)))
            existing_cat_ids = set(res.scalars().all())

        for i, cat in enumerate(categories_data):
            cat_id = cat.get("id")
            if cat_id and cat_id not in existing_cat_ids:
                session.add(
                    Category(
                        id=cat_id,
                        name=cat.get("name", cat_id.replace("_", " ").title()),
                        image_url=cat.get("imageUrl", ""),
                        sort_order=i,
                    )
                )
                existing_cat_ids.add(cat_id)

        # 3. Brands
        brands_data = data.get("brands", [])
        print(f"[Seed] Seeding {len(brands_data)} brands...")
        brand_ids = [brand.get("id") for brand in brands_data if brand.get("id")]
        existing_brand_ids = set()
        if brand_ids:
            res = await session.execute(select(Brand.id).where(Brand.id.in_(brand_ids)))
            existing_brand_ids = set(res.scalars().all())

        for brand in brands_data:
            brand_id = brand.get("id")
            if brand_id and brand_id not in existing_brand_ids:
                session.add(
                    Brand(
                        id=brand_id,
                        name=brand.get("name", brand_id.replace("_", " ").title()),
                        image_url=brand.get("imageUrl", ""),
                        category_id=brand.get("categoryId"),
                    )
                )
                existing_brand_ids.add(brand_id)

        # 4. Shops
        shops_data = data.get("shops", [])
        print(f"[Seed] Seeding {len(shops_data)} shops...")
        shop_ids = [shop.get("id") for shop in shops_data if shop.get("id")]
        existing_shop_ids = set()
        if shop_ids:
            res = await session.execute(select(Shop.id).where(Shop.id.in_(shop_ids)))
            existing_shop_ids = set(res.scalars().all())

        for shop in shops_data:
            shop_id = shop.get("id")
            if not shop_id or shop_id in existing_shop_ids:
                continue

            dist_val = 1.5
            try:
                dist_val = float(shop.get("distance", "1.5"))
            except (ValueError, TypeError):
                dist_val = 1.5

            session.add(
                Shop(
                    id=shop_id,
                    name=shop.get("name"),
                    logo_url=shop.get("logoUrl"),
                    cover_image_url=shop.get("coverImageUrl"),
                    rating=float(shop.get("rating", 4.5)),
                    review_count=int(shop.get("reviewCount", 50)),
                    address=shop.get("address", "Hyderabad"),
                    distance_km=dist_val,
                    is_open=shop.get("isOpen", True),
                    categories=shop.get("categories", []),
                    phone="+91 98480 22338",
                )
            )
            existing_shop_ids.add(shop_id)

        # 5. Products
        products_data = data.get("products", [])
        print(f"[Seed] Seeding {len(products_data)} products...")
        prod_ids = [prod.get("id") for prod in products_data if prod.get("id")]
        existing_prod_ids = set()
        if prod_ids:
            res = await session.execute(select(Product.id).where(Product.id.in_(prod_ids)))
            existing_prod_ids = set(res.scalars().all())

        for prod in products_data:
            prod_id = prod.get("id")
            if not prod_id or prod_id in existing_prod_ids:
                continue

            specs = prod.get("specifications", {})
            unit = specs.get("Unit", "unit") if isinstance(specs, dict) else "unit"
            session.add(
                Product(
                    id=prod_id,
                    title=prod.get("title") or prod.get("name") or "Construction Material",
                    description=prod.get("description", "High quality construction and building materials."),
                    price=float(prod.get("price", 100.0)),
                    original_price=float(prod.get("originalPrice", prod.get("price", 100.0))),
                    category_id=prod.get("categoryId", "cement"),
                    shop_id=prod.get("shopId", "shop_001"),
                    brand_id=prod.get("brandId"),
                    image_urls=prod.get("imageUrls", []),
                    specifications=specs if isinstance(specs, dict) else {},
                    rating=float(prod.get("rating", 4.5)),
                    total_reviews=int(prod.get("totalReviews", 10)),
                    stock_quantity=int(prod.get("stockQuantity", 100)),
                    unit=unit,
                    is_active=True,
                )
            )
            existing_prod_ids.add(prod_id)

        # 6. Banners
        banners_data = data.get("banners", [])
        print(f"[Seed] Seeding {len(banners_data)} banners...")
        banner_ids = [banner.get("id") for banner in banners_data if banner.get("id")]
        existing_banner_ids = set()
        if banner_ids:
            res = await session.execute(select(Banner.id).where(Banner.id.in_(banner_ids)))
            existing_banner_ids = set(res.scalars().all())

        for banner in banners_data:
            banner_id = banner.get("id")
            if banner_id and banner_id not in existing_banner_ids:
                session.add(
                    Banner(
                        id=banner_id,
                        title=banner.get("title", "Mega Construction Sale"),
                        subtitle=banner.get("subtitle", "Direct Factory Prices"),
                        image_url=banner.get("imageUrl", ""),
                        target_category=banner.get("targetUrl", "").replace("/category/", ""),
                        discount_text="Up to 30% OFF",
                        is_featured=True,
                    )
                )
                existing_banner_ids.add(banner_id)

        await session.commit()
        print("[Seed] Database seeding successfully completed!")


if __name__ == "__main__":
    asyncio.run(seed_database())
