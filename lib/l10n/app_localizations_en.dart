// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BuildMart';

  @override
  String get home => 'Home';

  @override
  String get categories => 'Categories';

  @override
  String get orders => 'Orders';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get voiceSearchListening => 'Listening...';

  @override
  String get voiceSearchError => 'Could not recognize speech';

  @override
  String get barcodeScanTitle => 'Scan Product Barcode';

  @override
  String get barcodeScanHint => 'Align barcode within the frame';

  @override
  String get aiVisionSearchTitle => 'AI Vision Search';

  @override
  String aiVisionAnalyzing(String imageName) {
    return 'Analyzing $imageName...';
  }

  @override
  String get searchHint => 'Search products...';

  @override
  String get popularBrands => 'Popular Brands';

  @override
  String get trendingProducts => 'Trending Products';

  @override
  String get nearbyShops => 'Nearby Shops';

  @override
  String get myOrders => 'My Orders';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get recentlyViewed => 'Recently Viewed';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get referralProgram => 'Referral Program';

  @override
  String get languagePreferences => 'Language Preferences';

  @override
  String get themePreferences => 'Theme Preferences';

  @override
  String get helpCenter => 'Help Center & FAQs';

  @override
  String get refreshCatalog => 'Refresh Catalog Data';

  @override
  String get refreshingCatalog => 'Refreshing Catalog...';

  @override
  String get logout => 'Logout';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get telugu => 'తెలుగు';

  @override
  String get myCart => 'My Cart';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryCharge => 'Delivery Charge';

  @override
  String get gst => 'GST (18%)';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String deliveringTo(String location) {
    return 'Delivering to $location';
  }

  @override
  String get location => 'Location';

  @override
  String get homeLocation => 'Home';

  @override
  String get selectDeliveryLocation => 'Select delivery location';

  @override
  String get products => 'Products';

  @override
  String get all => 'All';

  @override
  String get sort => 'Sort';

  @override
  String get filter => 'Filter';

  @override
  String get inStock => 'In Stock';

  @override
  String get seeAll => 'See All';

  @override
  String get noProductsFound => 'No products found.';

  @override
  String get saveForLater => 'Save for Later';

  @override
  String get enterPromoCode => 'Enter Promo Code';

  @override
  String get apply => 'Apply';

  @override
  String get requestEstimate => 'Request Estimate';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faq1Q => 'How do I track my order?';

  @override
  String get faq1A =>
      'You can track your order by going to the Profile screen and tapping on \"My Orders\". Click on the active order to see its live status.';

  @override
  String get faq2Q => 'What is the return policy?';

  @override
  String get faq2A =>
      'We offer a 7-day hassle-free return policy for unused products in their original packaging. Heavy materials like cement or steel might be subject to different terms.';

  @override
  String get faq3Q => 'How can I get bulk discounts?';

  @override
  String get faq3A =>
      'For wholesale pricing or bulk orders, please contact our support team directly. We offer customized pricing for large construction projects.';

  @override
  String get faq4Q => 'What are the delivery charges?';

  @override
  String get faq4A =>
      'Delivery charges depend on the distance from the nearest shop and the weight of your items. The final delivery cost will be calculated at checkout.';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get chatSupport => 'Chat with Support';

  @override
  String get chatSupportSub => 'Usually replies within 5 minutes';

  @override
  String get emailUs => 'Email Us';

  @override
  String get callUs => 'Call Us';

  @override
  String get savedCards => 'Saved Cards';

  @override
  String get cardEnding1234 => 'Card ending in 1234';

  @override
  String get cardEnding9876 => 'Card ending in 9876';

  @override
  String get upiWallets => 'UPI / Wallets';

  @override
  String get cash => 'Cash';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get addNewPaymentMethod => 'Add New Payment Method';
}
