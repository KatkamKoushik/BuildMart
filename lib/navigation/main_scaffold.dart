import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../features/profile/data/user_repository.dart';
import '../features/cart/data/cart_repository.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get cart item count for the badge
    final userState = ref.watch(userProvider);
    final userId = userState.value?.id;
    int cartItemCount = 0;
    if (userId != null) {
      final cartAsync = ref.watch(cartStreamProvider(userId));
      cartItemCount = cartAsync.when(
        data: (items) => items.fold<int>(0, (sum, item) => sum + item.quantity),
        loading: () => 0,
        error: (_, __) => 0,
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            selectedIcon: const Icon(Icons.category),
            label: AppLocalizations.of(context)!.categories,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartItemCount > 0,
              label: Text('$cartItemCount'),
              backgroundColor: Colors.red,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartItemCount > 0,
              label: Text('$cartItemCount'),
              backgroundColor: Colors.red,
              child: const Icon(Icons.shopping_cart),
            ),
            label: AppLocalizations.of(context)!.cart,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory),
            label: AppLocalizations.of(context)!.orders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ).animate().slideY(
          begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeOut),
    );
  }
}
