import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/otp_verification_screen.dart';
import '../features/auth/presentation/profile_completion_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/location/presentation/location_screen.dart';
import '../features/profile/presentation/wishlist_screen.dart';
import '../features/profile/presentation/recently_viewed_screen.dart';
import '../features/brands/presentation/brands_screen.dart';
import '../features/products/presentation/products_screen.dart';
import '../features/profile/presentation/payment_methods_screen.dart';
import '../features/profile/presentation/help_center_screen.dart';
import '../features/profile/presentation/support_chat_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/manage_products_screen.dart';
import '../features/products/presentation/product_details_screen.dart';
import '../features/shops/presentation/nearby_shops_screen.dart';
import '../features/shops/presentation/shop_details_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/checkout/presentation/payment_screen.dart';
import '../features/checkout/presentation/payment_success_screen.dart';
import '../features/orders/presentation/order_tracking_screen.dart';
import '../features/orders/presentation/delivery_success_screen.dart';
import '../features/checkout/presentation/quote_preview_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/search/presentation/barcode_scanner_screen.dart';
import 'main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _categoriesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'categories');
final GlobalKey<NavigatorState> _cartNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'cart');
final GlobalKey<NavigatorState> _ordersNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'orders');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  redirect: (context, state) {
    bool isLoggedIn = false;
    try {
      isLoggedIn = FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      // Safe fallback when Firebase is not initialized or offline
      isLoggedIn = false;
    }
    final path = state.uri.path;
    final isAuthRoute =
        path == '/welcome' || path == '/login' || path == '/otp';

    // Routes that require authentication to access (F-02 & F-14)
    final authRequiredRoutes = [
      '/checkout',
      '/payment',
      '/payment-success',
      '/orders',
      '/order-tracking',
      '/delivery-success',
      '/profile',
      '/profile-completion',
      '/wishlist',
      '/recently-viewed',
      '/admin',
      '/admin/manage-products',
    ];

    final requiresAuth =
        authRequiredRoutes.any((route) => path.startsWith(route));

    // If user tries to access an auth-required route without being logged in,
    // redirect to login
    if (!isLoggedIn && requiresAuth) {
      return '/login';
    }

    // If logged in but on an auth page, go to home
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/barcode-scanner',
      builder: (context, state) => const BarcodeScannerScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpVerificationScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/profile-completion',
      builder: (context, state) => const ProfileCompletionScreen(),
    ),
    GoRoute(
      path: '/location',
      builder: (context, state) => const LocationScreen(),
    ),
    GoRoute(
      path: '/brands',
      builder: (context, state) => const BrandsScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => ProductsScreen(
        query: state.uri.queryParameters['q'],
        categoryId: state.uri.queryParameters['categoryId'],
        brandId: state.uri.queryParameters['brandId'],
      ),
    ),
    GoRoute(
      path: '/shops',
      builder: (context, state) => const NearbyShopsScreen(),
    ),
    GoRoute(
      path: '/product-details/:id',
      builder: (context, state) =>
          ProductDetailsScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/shop-details',
      builder: (context, state) => const ShopDetailsScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/quote-preview',
      builder: (context, state) => const QuotePreviewScreen(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        final amount = state.extra as double? ?? 101590.0;
        return PaymentScreen(amount: amount);
      },
    ),
    GoRoute(
      path: '/payment-success',
      builder: (context, state) => const PaymentSuccessScreen(),
    ),
    GoRoute(
      path: '/order-tracking',
      builder: (context, state) => const OrderTrackingScreen(),
    ),
    GoRoute(
      path: '/delivery-success',
      builder: (context, state) => const DeliverySuccessScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/recently-viewed',
      builder: (context, state) => const RecentlyViewedScreen(),
    ),
    GoRoute(
      path: '/payment-methods',
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: '/help-center',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/support-chat',
      builder: (context, state) => const SupportChatScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/manage-products',
      builder: (context, state) => const ManageProductsScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _categoriesNavigatorKey,
          routes: [
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoriesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _cartNavigatorKey,
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _ordersNavigatorKey,
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
