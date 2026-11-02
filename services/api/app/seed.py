import asyncio
import json
from pathlib import Path

from app.core.security import hash_password
from app.db.session import AsyncSessionLocal, Base, engine
from app.models.models import (
    Banner,
    Brand,
    Category,
    Product,
    Shop,
    User,
)
from sqlalchemy import select

DEFAULT_DEV_PASSWORD = "DevPass123!"

async def get_or_create_seed_user(session, email: str, role: str, name: str) -> User:
    res = await session.execute(select(User).where(User.email == email))
    user = res.scalars().first()
    if not user:
        user = User(
            id=f"usr_{role}_{email.split('@')[0]}",
            name=name,
            email=email,
            phone="9876543210",
            hashed_password=hash_password(DEFAULT_DEV_PASSWORD),
            role=role,
            saved_addresses=[
                {
                    "id": "addr_001",
                    "fullName": name,
                    "addressLine1": "Plot 42, Hitec City Phase 2",
                    "addressLine2": "Near Cyber Towers",
                    "city": "Hyderabad",
                    "state": "Telangana",
                    "postalCode": "500081",
                    "phone": "9876543210",
                    "isDefault": True
                }
            ]
        )
        session.add(user)
        await session.commit()
    elif not user.hashed_password:
        user.hashed_password = hash_password(DEFAULT_DEV_PASSWORD)
        await session.commit()
    return user


async def seed_database(session_factory=None):
    target_engine = (
        session_factory.kw["bind"]
        if (session_factory and hasattr(session_factory, "kw") and "bind" in session_factory.kw)
        else engine
    )
    print("[Seed] Initializing database schema...")
    async with target_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Resolve seed file path safely across local, container, and test environments
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
        # 1. Create or get Default Demo Users (Buyer, Admin, Seller)
        print("[Seed] Seeding default demo users with secure bcrypt hashes...")
        await get_or_create_seed_user(
            session, email="buyer@buildmart.dev", role="buyer", name="BuildMart Demo Buyer"
        )
        await get_or_create_seed_user(
            session, email="admin@buildmart.dev", role="admin", name="BuildMart Super Admin"
        )
        await get_or_create_seed_user(
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

        for cat in categories_data:
            cat_id = cat.get("id")
            if cat_id not in existing_cat_ids:
                category = Category(
                    id=cat_id,
                    name=cat.get("name"),
                    image_url=cat.get("imageUrl") or "",
                    sort_order=cat.get("sortOrder", 0)
                )
                session.add(category)
        await session.commit()

        # 3. Brands
        brands_data = data.get("brands", [])
        print(f"[Seed] Seeding {len(brands_data)} brands...")
        brand_ids = [b.get("id") for b in brands_data if b.get("id")]
        existing_brand_ids = set()
        if brand_ids:
            res = await session.execute(select(Brand.id).where(Brand.id.in_(brand_ids)))
            existing_brand_ids = set(res.scalars().all())

        for b in brands_data:
            b_id = b.get("id")
            if b_id not in existing_brand_ids:
                brand = Brand(
                    id=b_id,
                    name=b.get("name"),
                    image_url=b.get("imageUrl") or "",
                    category_id=b.get("categoryId")
                )
                session.add(brand)
        await session.commit()

        # 4. Shops / Yards
        shops_data = data.get("shops", [])
        print(f"[Seed] Seeding {len(shops_data)} shops...")
        shop_ids = [s.get("id") for s in shops_data if s.get("id")]
        existing_shop_ids = set()
        if shop_ids:
            res = await session.execute(select(Shop.id).where(Shop.id.in_(shop_ids)))
            existing_shop_ids = set(res.scalars().all())

        for s in shops_data:
            s_id = s.get("id")
            if s_id not in existing_shop_ids:
                shop = Shop(
                    id=s_id,
                    name=s.get("name"),
                    logo_url=s.get("logoUrl"),
                    cover_image_url=s.get("coverImageUrl"),
                    rating=s.get("rating", 4.5),
                    review_count=s.get("reviewCount", 0),
                    address=s.get("address", ""),
                    latitude=s.get("latitude"),
                    longitude=s.get("longitude"),
                    distance_km=s.get("distanceKm", 1.5),
                    is_open=s.get("isOpen", True),
                    categories=s.get("categories", []),
                    phone=s.get("phone")
                )
                session.add(shop)
        await session.commit()

        # 5. Products
        products_data = data.get("products", [])
        print(f"[Seed] Seeding {len(products_data)} products...")
        prod_ids = [p.get("id") for p in products_data if p.get("id")]
        existing_prod_ids = set()
        if prod_ids:
            res = await session.execute(select(Product.id).where(Product.id.in_(prod_ids)))
            existing_prod_ids = set(res.scalars().all())

        for p in products_data:
            p_id = p.get("id")
            if p_id not in existing_prod_ids:
                product = Product(
                    id=p_id,
                    title=p.get("title"),
                    description=p.get("description"),
                    price=float(p.get("price", 0.0)),
                    original_price=float(p.get("originalPrice", 0.0)) if p.get("originalPrice") else None,
                    category_id=p.get("categoryId"),
                    shop_id=p.get("shopId"),
                    brand_id=p.get("brandId"),
                    image_urls=p.get("imageUrls", []),
                    specifications=p.get("specifications", {}),
                    rating=p.get("rating", 4.5),
                    total_reviews=p.get("totalReviews", 0),
                    stock_quantity=p.get("stockQuantity", 100),
                    unit=p.get("unit", "unit"),
                    is_active=p.get("isActive", True)
                )
                session.add(product)
        await session.commit()

        # 6. Banners
        banners_data = data.get("banners", [])
        print(f"[Seed] Seeding {len(banners_data)} banners...")
        banner_ids = [bn.get("id") for bn in banners_data if bn.get("id")]
        existing_banner_ids = set()
        if banner_ids:
            res = await session.execute(select(Banner.id).where(Banner.id.in_(banner_ids)))
            existing_banner_ids = set(res.scalars().all())

        for bn in banners_data:
            bn_id = bn.get("id")
            if bn_id not in existing_banner_ids:
                banner = Banner(
                    id=bn_id,
                    title=bn.get("title"),
                    subtitle=bn.get("subtitle"),
                    image_url=bn.get("imageUrl") or "",
                    target_category=bn.get("targetCategory"),
                    discount_text=bn.get("discountText"),
                    is_featured=bn.get("isFeatured", True)
                )
                session.add(banner)
        await session.commit()

        print("[Seed] Database seeding successfully completed!")

if __name__ == "__main__":
    asyncio.run(seed_database())
