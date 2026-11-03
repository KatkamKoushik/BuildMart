import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/user_model.dart';
import '../../../core/security/secure_storage.dart';
import '../../auth/data/auth_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final userProvider = StreamProvider<UserModel?>((ref) async* {
  final repository = ref.watch(userRepositoryProvider);

  Future<UserModel?> resolveUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return await repository.getUserOnce(firebaseUser.uid);
    }
    final token = await secureStorage.getToken();
    final uid = await secureStorage.getUserId();
    if (token != null && token.isNotEmpty && uid != null && uid.isNotEmpty) {
      return await repository.getUserOnce(uid);
    }
    return null;
  }

  // Emit current user immediately
  yield await resolveUser();

  // Stream reactive updates
  final controller = StreamController<UserModel?>.broadcast();
  ref.onDispose(() => controller.close());

  void checkUser() async {
    final u = await resolveUser();
    if (!controller.isClosed) {
      controller.add(u);
    }
  }

  final sub1 = authRepository.authStateStream.listen((_) => checkUser());
  final sub2 =
      FirebaseAuth.instance.authStateChanges().listen((_) => checkUser());
  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
  });

  yield* controller.stream;
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<UserModel> _buildFallbackUserModel(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final cachedName =
        prefs.getString('cached_user_name') ?? firebaseUser?.displayName ?? '';
    final cachedEmail =
        prefs.getString('cached_user_email') ?? firebaseUser?.email ?? '';
    final cachedPhone =
        prefs.getString('cached_user_phone') ?? firebaseUser?.phoneNumber ?? '';
    final cachedPhoto =
        prefs.getString('cached_user_photo') ?? firebaseUser?.photoURL;
    final savedAddrs =
        prefs.getStringList('saved_addresses_$uid') ?? const <String>[];

    return UserModel(
      id: uid,
      name: cachedName.isNotEmpty
          ? cachedName
          : (cachedEmail.isNotEmpty ? cachedEmail.split('@')[0] : 'User'),
      email: cachedEmail,
      phone: cachedPhone,
      profileImageUrl: cachedPhoto,
      savedAddresses: savedAddrs,
    );
  }

  Future<UserModel> getUserOnce(String uid) async {
    final fallbackUser = await _buildFallbackUserModel(uid);
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 1));
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id;
        data['name'] = data['name'] ?? fallbackUser.name;
        data['email'] = data['email'] ?? fallbackUser.email;
        data['phone'] = data['phone'] ?? fallbackUser.phone;
        data['savedAddresses'] =
            data['savedAddresses'] ?? fallbackUser.savedAddresses;
        return UserModel.fromJson(data);
      }
    } catch (_) {}
    return fallbackUser;
  }

  Stream<UserModel?> watchUser(String uid) async* {
    final fallbackUser = await _buildFallbackUserModel(uid);
    yield fallbackUser;

    try {
      yield* _firestore.collection('users').doc(uid).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          return fallbackUser;
        }
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id;
        data['name'] = data['name'] ?? fallbackUser.name;
        data['email'] = data['email'] ?? fallbackUser.email;
        data['phone'] = data['phone'] ?? fallbackUser.phone;
        data['savedAddresses'] =
            data['savedAddresses'] ?? fallbackUser.savedAddresses;
        return UserModel.fromJson(data);
      }).handleError((error) {
        debugPrint('[UserRepository] Firestore user stream fallback: $error');
        return fallbackUser;
      });
    } catch (e) {
      debugPrint('[UserRepository] Firestore error: $e');
      yield fallbackUser;
    }
  }

  Future<void> updateUserProfileImage(String uid, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user_photo', imageUrl);
    try {
      await _firestore.collection('users').doc(uid).set(
        {'profileImageUrl': imageUrl},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[UserRepository] Firestore profile image sync skipped: $e');
    }
  }

  Future<void> updateUserName(String uid, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user_name', name);
    try {
      await _firestore.collection('users').doc(uid).set(
        {'name': name},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[UserRepository] Firestore user name sync skipped: $e');
    }
  }

  Future<void> addSavedAddress(String uid, String addressLine) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_addresses_$uid';
    final currentList = prefs.getStringList(key) ?? [];
    if (!currentList.contains(addressLine)) {
      currentList.insert(0, addressLine);
      await prefs.setStringList(key, currentList);
    }

    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'savedAddresses': FieldValue.arrayUnion([addressLine])
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[UserRepository] Firestore address sync skipped: $e');
    }
  }
}
