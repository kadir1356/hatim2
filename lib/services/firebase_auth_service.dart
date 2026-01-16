import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();
  final FirebaseFirestore? _firestore = kIsWeb ? null : FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      // Create user profile in Firestore
      await _createUserProfile(credential.user!.uid, displayName, email);

      return credential;
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  Future<void> _createUserProfile(String uid, String displayName, String email) async {
    if (kIsWeb || _firestore == null) return;
    try {
      await _firestore!.collection('users').doc(uid).set({
        'display_name': displayName,
        'email': email,
        'joined_date': FieldValue.serverTimestamp(),
        'last_read_page': 1, // Default to page 1
        'last_read_juz': null,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // Update last read page
  Future<void> updateLastReadPage(int pageNumber, {int? juzNumber}) async {
    if (kIsWeb || _firestore == null) return;
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore!.collection('users').doc(user.uid).update({
          'last_read_page': pageNumber,
          'last_read_juz': juzNumber,
          'last_read_timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating last read page: $e');
    }
  }

  // Get last read page
  Future<Map<String, dynamic>?> getLastReadPage() async {
    if (kIsWeb || _firestore == null) return null;
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore!.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return {
            'page': doc.data()?['last_read_page'] ?? 1,
            'juz': doc.data()?['last_read_juz'],
          };
        }
      }
    } catch (e) {
      print('Error getting last read page: $e');
    }
    return null;
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb || _googleSignIn == null) return null;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Create user profile if doesn't exist
      if (userCredential.user != null) {
        await _createUserProfile(
          userCredential.user!.uid,
          userCredential.user!.displayName ?? 'User',
          userCredential.user!.email ?? '',
        );
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      final UserCredential credential = await _auth.signInAnonymously();
      
      // Create user profile for anonymous user
      if (credential.user != null) {
        await _createUserProfile(
          credential.user!.uid,
          'Anonymous User',
          '',
        );
      }
      
      return credential;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb && _googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
