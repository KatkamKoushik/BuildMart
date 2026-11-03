import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/security/secure_storage.dart';
import '../../../core/services/api_client.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '3441164208-11vm9eu2chebstg97muifnqt40bp4un8.apps.googleusercontent.com',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SecureStorage _storage = secureStorage;
  final ApiClient _apiClient = ApiClient();

  String? _verificationId;
  bool _isLoggedIn = false;
  final ValueNotifier<bool> authStateListenable = ValueNotifier<bool>(false);
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  Stream<bool> get authStateStream => _authStateController.stream;

  bool get isLoggedInSync {
    try {
      if (_auth.currentUser != null) return true;
    } catch (_) {}
    return _isLoggedIn;
  }

  AuthRepository() {
    _initAuthState();
  }

  Future<void> _initAuthState() async {
    try {
      _auth.authStateChanges().listen((user) async {
        if (user != null) {
          _isLoggedIn = true;
          authStateListenable.value = true;
          _authStateController.add(true);
        } else {
          final token = await _storage.getToken();
          final hasToken = token != null && token.isNotEmpty;
          _isLoggedIn = hasToken;
          authStateListenable.value = hasToken;
          _authStateController.add(hasToken);
        }
      });
    } catch (e) {
      debugPrint('[AuthRepository] Firebase authStateChanges init warning: $e');
    }

    try {
      final token = await _storage.getToken();
      final hasToken =
          (token != null && token.isNotEmpty) || _auth.currentUser != null;
      _isLoggedIn = hasToken;
      authStateListenable.value = hasToken;
      _authStateController.add(hasToken);
    } catch (e) {
      debugPrint('[AuthRepository] Token check error: $e');
    }
  }

  void _notifyAuthSuccess() {
    _isLoggedIn = true;
    authStateListenable.value = true;
    _authStateController.add(true);
  }

  void _notifyAuthLogout() {
    _isLoggedIn = false;
    authStateListenable.value = false;
    _authStateController.add(false);
  }

  Future<bool> verifyPhoneNumber(
    String phoneNumber, {
    required Function(String, int?) onCodeSent,
    required Function(String) onError,
  }) async {
    final completer = Completer<bool>();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            if (userCredential.user != null) {
              final user = userCredential.user!;
              final token = await user.getIdToken();
              if (token != null) {
                await _storage.saveToken(token);
              }
              await _storage.saveUserId(user.uid);

              try {
                final doc =
                    await _firestore.collection('users').doc(user.uid).get();
                if (!doc.exists) {
                  await _firestore.collection('users').doc(user.uid).set({
                    'phone': user.phoneNumber ?? '',
                    'name': user.displayName ?? 'New User',
                    'email': user.email ?? '',
                    'profileImageUrl': user.photoURL ?? '',
                  });
                }
              } catch (_) {}

              _notifyAuthSuccess();
            }
          } catch (e) {
            debugPrint('[AuthRepository] Auto-verification sign-in error: $e');
          }
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId, resendToken);
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return await completer.future;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) return false;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final token = await user.getIdToken();
        if (token != null) {
          await _storage.saveToken(token);
        }
        await _storage.saveUserId(user.uid);

        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (!doc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'phone': user.phoneNumber ?? '',
              'name': user.displayName ?? 'New User',
              'email': user.email ?? '',
              'profileImageUrl': user.photoURL ?? '',
            });
          }
        } catch (e) {
          debugPrint('[AuthRepository] Notice: Firestore sync bypassed: $e');
        }

        _notifyAuthSuccess();
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
        final GoogleSignInAuthentication googleAuth =
            await account.authentication;

        AuthCredential? credential;
        if (googleAuth.idToken != null || googleAuth.accessToken != null) {
          credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
        }

        User? user;
        if (credential != null) {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            user = userCredential.user;
          } catch (e) {
            debugPrint(
                '[AuthRepository] Firebase signInWithCredential warning: $e');
          }
        }

        final uid = user?.uid ?? account.id;
        final token = (await user?.getIdToken()) ??
            googleAuth.idToken ??
            'google_oauth_token';
        await _storage.saveToken(token);
        await _storage.saveUserId(uid);

        final prefs = await SharedPreferences.getInstance();
        final displayName =
            account.displayName ?? user?.displayName ?? 'BuildMart User';
        final email = account.email;
        final photoUrl = account.photoUrl ?? user?.photoURL ?? '';
        await prefs.setString('cached_user_name', displayName);
        await prefs.setString('cached_user_email', email);
        await prefs.setString('cached_user_photo', photoUrl);
        await prefs.setString('cached_user_role', 'buyer');

        // Sync with backend API
        try {
          await _apiClient.post(
            '/auth/firebase',
            body: {
              'firebase_token': token,
              'email': email,
              'name': displayName,
            },
            auth: false,
          );
        } catch (_) {}

        // Graceful user profile document sync
        try {
          final doc = await _firestore.collection('users').doc(uid).get();
          if (!doc.exists) {
            await _firestore.collection('users').doc(uid).set({
              'email': email,
              'name': displayName,
              'phone': user?.phoneNumber ?? '',
              'profileImageUrl': photoUrl,
            });
          }
        } catch (e) {
          debugPrint(
              '[AuthRepository] Notice: Firestore user sync bypassed: $e');
        }

        _notifyAuthSuccess();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return false;
    }
  }

  Future<String?> _tryBackendApiLogin(String email, String password) async {
    try {
      final res = await _apiClient.post(
        '/auth/login',
        body: {'email': email.trim(), 'password': password},
        auth: false,
      );
      if (res is Map && res['access_token'] != null) {
        final token = res['access_token'].toString();
        await _storage.saveToken(token);
        final userData = res['user'] as Map<String, dynamic>?;
        final uid = userData?['id']?.toString() ?? 'usr_buyer_backend';
        await _storage.saveUserId(uid);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'cached_user_name', userData?['name'] ?? 'BuildMart Buyer');
        await prefs.setString('cached_user_email', userData?['email'] ?? email);
        await prefs.setString('cached_user_role', userData?['role'] ?? 'buyer');

        debugPrint(
            '[AuthRepository] Successfully authenticated via Backend API for $email');
        _notifyAuthSuccess();
        return null;
      }
    } catch (e) {
      debugPrint('[AuthRepository] Backend API login attempt failed: $e');
    }
    return 'Authentication failed. Please verify credentials.';
  }

  Future<String?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;
        final token = await user.getIdToken();
        if (token != null) {
          await _storage.saveToken(token);
        }
        await _storage.saveUserId(user.uid);

        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final data = doc.data();
            final prefs = await SharedPreferences.getInstance();
            if (data?['name'] != null) {
              await prefs.setString('cached_user_name', data!['name']);
            }
            if (data?['email'] != null) {
              await prefs.setString('cached_user_email', data!['email']);
            }
          }
        } catch (_) {}

        _notifyAuthSuccess();
        return null;
      }
      return 'Failed to authenticate user';
    } catch (e) {
      debugPrint('Firebase email login error: $e');
      return await _tryBackendApiLogin(email, password);
    }
  }

  Future<String?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      final res = await _apiClient.post(
        '/auth/register',
        body: {
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
        },
        auth: false,
      );
      if (res is Map && res['id'] != null) {
        return await loginWithEmail(email, password);
      }
    } catch (e) {
      debugPrint('[AuthRepository] Backend registration failed: $e');
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;
        await user.updateDisplayName(name);
        final token = await user.getIdToken();
        if (token != null) {
          await _storage.saveToken(token);
        }
        await _storage.saveUserId(user.uid);

        try {
          await _firestore.collection('users').doc(user.uid).set({
            'email': email.trim(),
            'name': name.trim(),
            'phone': '',
            'profileImageUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_user_name', name.trim());
        await prefs.setString('cached_user_email', email.trim());

        _notifyAuthSuccess();
        return null;
      }
      return 'Failed to create user account';
    } catch (e) {
      debugPrint('Email signup error: $e');
      return e.toString();
    }
  }

  Future<String?> loginWithPhone(String phoneNumber) async {
    final completer = Completer<String?>();
    final success = await verifyPhoneNumber(
      phoneNumber,
      onCodeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) completer.complete(null);
      },
      onError: (error) {
        if (!completer.isCompleted) completer.complete(error);
      },
    );
    if (!success && !completer.isCompleted) {
      completer.complete('Failed to initiate phone verification');
    }
    return await completer.future;
  }

  Future<bool> verifyOtp(String phoneNumber, String smsCode) async {
    return await verifyOTP(smsCode);
  }

  Future<String?> loginDemoUser() async {
    return await _tryBackendApiLogin('buyer@buildmart.dev', 'DevPass123!');
  }

  Future<bool> completeProfile(String name, String? email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_name', name.trim());
      if (email != null && email.isNotEmpty) {
        await prefs.setString('cached_user_email', email.trim());
      }

      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'name': name.trim(),
            if (email != null && email.isNotEmpty) 'email': email.trim(),
          }, SetOptions(merge: true));
        } catch (_) {}
      }
      return true;
    } catch (e) {
      debugPrint('[AuthRepository] completeProfile error: $e');
      return false;
    }
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
      debugPrint('Firebase sign out error: $e');
    }
    await _storage.clearAll();
    _notifyAuthLogout();
  }

  Future<bool> isAuthenticated() async {
    try {
      if (_auth.currentUser != null) return true;
    } catch (_) {}
    final token = await _storage.getToken();
    return (token != null && token.isNotEmpty) || _isLoggedIn;
  }
}

final authRepository = AuthRepository();
