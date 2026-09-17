import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

class CacheService {
  static const String _userBox = 'userBox';
  static const String _productsBox = 'productsBox';
  static const String _ordersBox = 'ordersBox';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_userBox);
    await Hive.openBox(_productsBox);
    await Hive.openBox(_ordersBox);
  }

  // Generic Write
  Future<void> writeData(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  // Generic Read
  dynamic readData(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key);
  }

  // Generic Delete
  Future<void> deleteData(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }
  
  // Clear all
  Future<void> clearAll() async {
    await Hive.box(_userBox).clear();
    await Hive.box(_productsBox).clear();
    await Hive.box(_ordersBox).clear();
  }

  String get userBox => _userBox;
  String get productsBox => _productsBox;
  String get ordersBox => _ordersBox;
}
