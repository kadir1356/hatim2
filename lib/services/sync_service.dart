import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/storage_service.dart';
import '../services/firebase_auth_service.dart';

class SyncService {
  final FirebaseFirestore? _firestore = kIsWeb ? null : FirebaseFirestore.instance;
  final FirebaseAuthService _authService;
  final StorageService _storageService;

  SyncService(this._authService, this._storageService);

  bool get isSignedIn => _authService.isSignedIn;
  String? get userId => _authService.currentUser?.uid;

  Future<bool> syncToFirestore() async {
    if (kIsWeb || _firestore == null || !isSignedIn || userId == null) {
      return false;
    }

    try {
      // Sync Hatims
      final hatims = _storageService.getAllHatims();
      final batch = _firestore!.batch();

      for (var hatim in hatims) {
        final hatimRef = _firestore!
            .collection('users')
            .doc(userId)
            .collection('hatims')
            .doc(hatim.id);

        batch.set(hatimRef, {
          'id': hatim.id,
          'name': hatim.name,
          'createdAt': hatim.createdAt.toIso8601String(),
          'isActive': hatim.isActive,
          'pages': hatim.pages.map((p) => {
            'pageNumber': p.pageNumber,
            'juzNumber': p.juzNumber,
            'surahNumbers': p.surahNumbers,
            'isRead': p.isRead,
            'readDate': p.readDate?.toIso8601String(),
          }).toList(),
          'lastSynced': FieldValue.serverTimestamp(),
        });
      }

      // Sync Reading Sessions
      final sessions = _storageService.getReadingSessions();
      for (var session in sessions) {
        final sessionRef = _firestore!
            .collection('users')
            .doc(userId)
            .collection('reading_sessions')
            .doc('${session.date.millisecondsSinceEpoch}_${session.hatimId}');

        batch.set(sessionRef, {
          'date': session.date.toIso8601String(),
          'pagesRead': session.pagesRead,
          'hatimId': session.hatimId,
          'lastSynced': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error syncing to Firestore: $e');
      return false;
    }
  }

  Future<bool> syncFromFirestore() async {
    if (kIsWeb || _firestore == null || !isSignedIn || userId == null) {
      return false;
    }

    try {
      // Sync Hatims from Firestore
      final hatimsSnapshot = await _firestore!
          .collection('users')
          .doc(userId)
          .collection('hatims')
          .get();

      for (var doc in hatimsSnapshot.docs) {
        // Merge with local data - you can implement merge logic here
        // For now, we'll just update if local doesn't exist
        doc.data(); // Keep for future implementation
      }

      // Sync Reading Sessions
      final sessionsSnapshot = await _firestore!
          .collection('users')
          .doc(userId)
          .collection('reading_sessions')
          .get();

      for (var doc in sessionsSnapshot.docs) {
        // Merge logic here
        doc.data(); // Keep for future implementation
      }

      return true;
    } catch (e) {
      print('Error syncing from Firestore: $e');
      return false;
    }
  }

  Future<bool> sync() async {
    // Two-way sync: push local to cloud, then pull cloud to local
    final pushSuccess = await syncToFirestore();
    if (pushSuccess) {
      await syncFromFirestore();
      return true;
    }
    return false;
  }
}
