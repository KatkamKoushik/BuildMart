import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final userProvider = StreamProvider<UserModel?>((ref) {
  final authState = FirebaseAuth.instance.authStateChanges();
  return authState.asyncExpand((User? firebaseUser) {
    if (firebaseUser == null) {
      return Stream.value(null);
    }
    final repository = ref.watch(userRepositoryProvider);
    return repository.watchUser(firebaseUser.uid);
  });
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Stream<UserModel?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return UserModel.fromJson(data);
    });
  }

  Future<void> updateUserProfileImage(String uid, String imageUrl) async {
    await _firestore.collection('users').doc(uid).set(
      {'profileImageUrl': imageUrl},
      SetOptions(merge: true),
    );
  }

  Future<void> updateUserName(String uid, String name) async {
    await _firestore.collection('users').doc(uid).set(
      {'name': name},
      SetOptions(merge: true),
    );
  }

  Future<void> addSavedAddress(String uid, String addressLine) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'savedAddresses': FieldValue.arrayUnion([addressLine])
      },
      SetOptions(merge: true),
    );
  }
}
