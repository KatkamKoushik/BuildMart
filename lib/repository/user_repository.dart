import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/error/failures.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository(this._firestore, this._auth);

  Future<UserModel> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ServerFailure('User not authenticated');
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      } else {
        // Return a default model for demo purposes if user doesn't exist in Firestore
        return UserModel(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          profileImageUrl: user.photoURL,
        );
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
