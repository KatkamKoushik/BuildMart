import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteShopsProvider = StateNotifierProvider<FavoriteShopsNotifier, Set<String>>((ref) {
  return FavoriteShopsNotifier();
});

class FavoriteShopsNotifier extends StateNotifier<Set<String>> {
  FavoriteShopsNotifier() : super({});

  void toggleFavorite(String shopId) {
    if (state.contains(shopId)) {
      state = {...state}..remove(shopId);
    } else {
      state = {...state}..add(shopId);
    }
  }

  bool isFavorite(String shopId) {
    return state.contains(shopId);
  }
}
