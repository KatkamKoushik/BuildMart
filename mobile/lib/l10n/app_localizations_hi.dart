// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'बिल्डमार्ट';

  @override
  String get home => 'होम';

  @override
  String get categories => 'श्रेणियाँ';

  @override
  String get orders => 'ऑर्डर';

  @override
  String get cart => 'कार्ट';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get voiceSearchListening => 'सुन रहा हूँ...';

  @override
  String get voiceSearchError => 'आवाज़ नहीं पहचान सका';

  @override
  String get barcodeScanTitle => 'उत्पाद बारकोड स्कैन करें';

  @override
  String get barcodeScanHint => 'फ्रेम के भीतर बारकोड रखें';

  @override
  String get aiVisionSearchTitle => 'AI विज़न सर्च';

  @override
  String aiVisionAnalyzing(String imageName) {
    return '$imageName का विश्लेषण कर रहा हूँ...';
  }

  @override
  String get searchHint => 'उत्पाद खोजें...';

  @override
  String get popularBrands => 'लोकप्रिय ब्रांड';

  @override
  String get trendingProducts => 'ट्रेंडिंग उत्पाद';

  @override
  String get nearbyShops => 'पास की दुकानें';

  @override
  String get myOrders => 'मेरे ऑर्डर';

  @override
  String get wishlist => 'विशलिस्ट';

  @override
  String get recentlyViewed => 'हाल ही में देखे गए';

  @override
  String get myAddresses => 'मेरे पते';

  @override
  String get paymentMethods => 'भुगतान के तरीके';

  @override
  String get referralProgram => 'रेफरल प्रोग्राम';

  @override
  String get languagePreferences => 'भाषा प्राथमिकताएँ';

  @override
  String get themePreferences => 'थीम प्राथमिकताएँ';

  @override
  String get helpCenter => 'सहायता केंद्र';

  @override
  String get refreshCatalog => 'कैटलॉग रीफ्रेश करें';

  @override
  String get refreshingCatalog => 'कैटलॉग रीफ्रेश हो रहा है...';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get selectTheme => 'थीम चुनें';

  @override
  String get system => 'सिस्टम';

  @override
  String get light => 'लाइट';

  @override
  String get dark => 'डार्क';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get telugu => 'తెలుగు';

  @override
  String get myCart => 'मेरा कार्ट';

  @override
  String get subtotal => 'उप-योग';

  @override
  String get deliveryCharge => 'वितरण शुल्क';

  @override
  String get gst => 'जीएसटी (18%)';

  @override
  String get grandTotal => 'कुल योग';

  @override
  String get proceedToCheckout => 'चेकआउट के लिए आगे बढ़ें';

  @override
  String deliveringTo(String location) {
    return '$location पर डिलीवरी हो रही है';
  }

  @override
  String get location => 'स्थान';

  @override
  String get homeLocation => 'होम';

  @override
  String get selectDeliveryLocation => 'डिलीवरी स्थान चुनें';

  @override
  String get products => 'उत्पाद';

  @override
  String get all => 'सभी';

  @override
  String get sort => 'क्रमबद्ध करें';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get inStock => 'स्टॉक में';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get noProductsFound => 'कोई उत्पाद नहीं मिला।';

  @override
  String get saveForLater => 'बाद के लिए सहेजें';

  @override
  String get enterPromoCode => 'प्रोमो कोड दर्ज करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get requestEstimate => 'अनुमान का अनुरोध करें';

  @override
  String get faqTitle => 'सामान्य प्रश्न';

  @override
  String get faq1Q => 'मैं अपना ऑर्डर कैसे ट्रैक करूं?';

  @override
  String get faq1A =>
      'आप प्रोफ़ाइल स्क्रीन पर जाकर \"मेरे ऑर्डर\" पर टैप करके अपना ऑर्डर ट्रैक कर सकते हैं।';

  @override
  String get faq2Q => 'वापसी नीति क्या है?';

  @override
  String get faq2A =>
      'हम मूल पैकेजिंग में अप्रयुक्त उत्पादों के लिए 7 दिन की वापसी नीति प्रदान करते हैं।';

  @override
  String get faq3Q => 'मैं थोक छूट कैसे प्राप्त कर सकता हूं?';

  @override
  String get faq3A =>
      'थोक मूल्य निर्धारण के लिए, कृपया हमारी सहायता टीम से संपर्क करें।';

  @override
  String get faq4Q => 'डिलीवरी शुल्क क्या हैं?';

  @override
  String get faq4A =>
      'डिलीवरी शुल्क निकटतम दुकान से दूरी और आपके आइटम के वजन पर निर्भर करते हैं।';

  @override
  String get contactSupport => 'संपर्क करें';

  @override
  String get chatSupport => 'सहायता टीम से चैट करें';

  @override
  String get chatSupportSub => 'आमतौर पर 5 मिनट में जवाब';

  @override
  String get emailUs => 'हमें ईमेल करें';

  @override
  String get callUs => 'हमें कॉल करें';

  @override
  String get savedCards => 'सहेजे गए कार्ड';

  @override
  String get cardEnding1234 => '1234 में समाप्त होने वाला कार्ड';

  @override
  String get cardEnding9876 => '9876 में समाप्त होने वाला कार्ड';

  @override
  String get upiWallets => 'यूपीआई / वॉलेट';

  @override
  String get cash => 'नकद';

  @override
  String get cashOnDelivery => 'कैश ऑन डिलीवरी';

  @override
  String get addNewPaymentMethod => 'नई भुगतान विधि जोड़ें';
}
