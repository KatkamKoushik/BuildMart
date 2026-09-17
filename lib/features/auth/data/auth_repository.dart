import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/security/secure_storage.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SecureStorage _storage = secureStorage;

  String? _verificationId;

  Future<String?> loginWithPhone(String phoneNumber) async {
    final completer = Completer<String?>();
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution on Android
          final userCredential = await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            final token = await userCredential.user!.getIdToken();
            if (token != null) await _storage.saveToken(token);
            await _storage.saveUserId(userCredential.user!.uid);
          }
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone auth failed: ${e.message}');
          if (!completer.isCompleted) {
            completer.complete(e.message ?? 'Verification failed');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          // OTP was sent successfully, we can proceed to the OTP screen
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      
      return completer.future;
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return e.toString();
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    if (_verificationId == null) {
      debugPrint('Verification ID is null. Cannot verify OTP.');
      return false;
    }
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
        if (userCredential.user != null) {
          final user = userCredential.user!;
          final token = await user.getIdToken();
          if (token != null) {
            await _storage.saveToken(token);
          }
          await _storage.saveUserId(user.uid);
          
          // Create user document if it doesn't exist
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (!doc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'email': user.email ?? '',
              'name': user.displayName ?? 'New User',
              'phone': user.phoneNumber ?? phoneNumber,
              'profileImageUrl': user.photoURL ?? '',
            });
          }
          
          return true;
        }
      return false;
    } catch (e) {
      debugPrint('OTP Verification error: $e');
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication googleAuth = await account.authentication;
        
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        final userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          final user = userCredential.user!;
          final token = await user.getIdToken();
          if (token != null) {
            await _storage.saveToken(token);
          }
          await _storage.saveUserId(user.uid);
          
          // Create user document if it doesn't exist
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (!doc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'email': user.email ?? '',
              'name': user.displayName ?? 'New User',
              'phone': user.phoneNumber ?? '',
              'profileImageUrl': user.photoURL ?? '',
            });
          }
          
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return false;
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final token = await user.getIdToken();
        if (token != null) {
          await _storage.saveToken(token);
        }
        await _storage.saveUserId(user.uid);
        
        // Create user document if it doesn't exist
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email ?? email,
            'name': user.displayName ?? 'New User',
            'phone': user.phoneNumber ?? '',
            'profileImageUrl': user.photoURL ?? '',
          });
        }

        return null; // Success
      }
      return 'Login failed';
    } on FirebaseAuthException catch (e) {
      debugPrint('Email login error: ${e.message}');
      return e.message ?? 'Login failed';
    } catch (e) {
      debugPrint('Email login error: $e');
      return e.toString();
    }
  }

  Future<String?> signUpWithEmail(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final user = userCredential.user!;
        
        // Update display name
        await user.updateDisplayName(name);
        
        final token = await user.getIdToken();
        if (token != null) {
          await _storage.saveToken(token);
        }
        await _storage.saveUserId(user.uid);
        
        // Create user document
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'phone': '',
          'profileImageUrl': '',
        });
        
        return null; // Success
      }
      return 'Sign up failed';
    } on FirebaseAuthException catch (e) {
      debugPrint('Email signup error: ${e.message}');
      return e.message ?? 'Sign up failed';
    } catch (e) {
      debugPrint('Email signup error: $e');
      return e.toString();
    }
  }

  Future<bool> completeProfile(String name, String? email) async {
    // Simulate profile completion API call
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google sign out error: $e');
    }
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Firebase Auth sign out error: $e');
    }
    try {
      await _storage.clearAll();
    } catch (e) {
      debugPrint('Storage clear error: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    final user = _auth.currentUser;
    if (user != null) {
      return true;
    }
    
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }
}

final authRepository = AuthRepository();
