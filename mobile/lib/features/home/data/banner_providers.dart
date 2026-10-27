import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bannersProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('banners')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return doc.data()['imageUrl'] as String;
    }).toList();
  });
});
