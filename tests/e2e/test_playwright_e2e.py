import re
import pytest
from playwright.sync_api import Page, expect

def test_homepage_render_and_components(page: Page, live_servers: str):
    """
    Verifies that the BuildMart homepage loads successfully with all
    core sections: top banner, navigation header, hero carousel, category strip,
    and featured product catalog.
    """
    page.goto(live_servers, wait_until="networkidle")

    # 1. Page Title
    expect(page).to_have_title(re.compile(r"BuildMart", re.IGNORECASE))

    # 2. Top notification bar
    expect(page.locator("text=100% Genuine Certified Building Materials").first).to_be_visible()
    expect(page.locator("text=Free Delivery").first).to_be_visible()

    # 3. Header navigation elements
    expect(page.locator("header")).to_be_visible()
    expect(page.locator("a:has-text('BuildMart')").first).to_be_visible()
    expect(page.locator("input[placeholder*='Search']").first).to_be_visible()
    expect(page.locator("a[href='/quotes']:has-text('Get Quote')").first).to_be_visible()
    expect(page.locator("a[href='/shops']:has-text('Suppliers')").first).to_be_visible()
    expect(page.locator("a:has-text('Contractor Bulk Desk')").first).to_be_visible()

    # 4. Category strip
    category_strip = page.locator("h2:has-text('Shop by Material Category')")
    expect(category_strip).to_be_visible()

    # 5. Featured wholesale products section
    featured_heading = page.locator("h2:has-text('Verified Wholesale Products')")
    expect(featured_heading).to_be_visible()
    expect(page.locator("button[aria-label*='to cart']").first).to_be_visible()


def test_catalog_listing_and_search(page: Page, live_servers: str):
    """
    Verifies the product catalog page: navigation, breadcrumbs, search filtering,
    and product grid rendering.
    """
    page.goto(f"{live_servers}/products", wait_until="networkidle")

    # Breadcrumbs & Title
    expect(page.locator("a[href='/']:has-text('Home')").first).to_be_visible()
    expect(page.locator("h1:has-text('All Construction Materials')").first).to_be_visible()

    # Product cards presence
    product_cards = page.locator("div.glass-card")
    expect(product_cards.first).to_be_visible()

    # Search for Cement
    search_input = page.locator("input[placeholder*='Search']").first
    search_input.fill("Cement")
    search_input.press("Enter")

    page.wait_for_load_state("networkidle")
    expect(page).to_have_url(re.compile(r"q=Cement"))
    expect(page.locator("text=Cement").first).to_be_visible()


def test_product_detail_and_cart_drawer(page: Page, live_servers: str):
    """
    Verifies product detail page rendering, specification inspection,
    and adding items to the interactive cart drawer modal.
    """
    page.goto(f"{live_servers}/products", wait_until="networkidle")

    # Click first product card link
    first_product_link = page.locator("a[href*='/products/']").first
    first_product_link.click()

    page.wait_for_load_state("networkidle")
    expect(page).to_have_url(re.compile(r"/products/[a-zA-Z0-9_-]+"))

    # Verify product detail view
    add_to_cart_btn = page.locator("button:has-text('Add to Cart')").first
    expect(add_to_cart_btn).to_be_visible()

    # Click Add to Cart
    add_to_cart_btn.click()

    # Verify CartDrawer modal opens
    cart_drawer = page.locator("#cart-drawer-modal")
    expect(cart_drawer).to_be_visible(timeout=5000)
    expect(cart_drawer.locator("h2:has-text('Your Cart')")).to_be_visible()

    # Close CartDrawer
    close_btn = page.locator("#cart-drawer-close")
    expect(close_btn).to_be_visible()
    close_btn.click()
    expect(cart_drawer).not_to_be_visible()


def test_quotes_rfq_submission_workflow(page: Page, live_servers: str):
    """
    Verifies the Contractor Bulk Request for Quote (RFQ) workflow:
    form rendering, field inputs, validation, and confirmation generation.
    """
    page.goto(f"{live_servers}/quotes", wait_until="networkidle")

    expect(page.locator("h1:has-text('Request Commercial Project Estimate')")).to_be_visible()

    # Fill customer details
    page.locator("input[placeholder*='Skyline Infrastructure']").fill("E2E Test Contractor")
    page.locator("input[placeholder*='procurement@skyline']").fill("contractor@buildmart.dev")
    page.locator("input[placeholder='9876543210']").fill("9876543210")
    page.locator("input[placeholder*='Horizon Heights']").fill("Skyline Tower Project")

    # Submit RFQ
    submit_btn = page.locator("button:has-text('Generate Official Quote PDF')")
    expect(submit_btn).to_be_visible()
    submit_btn.click()

    # Verify success confirmation
    confirmation = page.locator("h2:has-text('Quotation Generated Successfully!')")
    expect(confirmation).to_be_visible(timeout=10000)
    expect(page.locator("text=Your official estimate reference is")).to_be_visible()
    expect(page.locator("a:has-text('Download Official PDF Quotation')")).to_be_visible()


def test_shops_supplier_directory(page: Page, live_servers: str):
    """
    Verifies the supplier yards and shops directory page rendering.
    """
    page.goto(f"{live_servers}/shops", wait_until="networkidle")

    expect(page.locator("h1:has-text('Authorized Material Yards & Suppliers')")).to_be_visible()
    expect(page.locator("div.glass-card").first).to_be_visible()
    expect(page.locator("text=km away").first).to_be_visible()


def test_responsive_mobile_viewport(page: Page, live_servers: str):
    """
    Verifies mobile viewport responsiveness (375x667):
    ensures proper layout adaptation and presence of mobile controls.
    """
    page.set_viewport_size({"width": 375, "height": 667})
    page.goto(live_servers, wait_until="networkidle")

    expect(page.locator("header")).to_be_visible()
    expect(page.locator("a:has-text('BuildMart')").first).to_be_visible()

    # Mobile cart toggle button should be visible
    cart_btn = page.locator("button[aria-label*='cart' i], button:has(svg.lucide-shopping-cart)").first
    expect(cart_btn).to_be_visible()
