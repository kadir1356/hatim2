/// LOCAL AUTH SERVICE (Firebase Disabled)
/// This is a stub service for local-only authentication
/// All methods return null/empty as no cloud auth is available

class LocalAuthService {
  /// Check if user is signed in (always false in local mode)
  bool get isSignedIn => false;

  /// Get current user (always null in local mode)
  dynamic get currentUser => null;

  /// Sign in anonymously (local mode - does nothing)
  Future<void> signInAnonymously() async {
    // Local mode - no Firebase
  }

  /// Sign out (local mode - does nothing)
  Future<void> signOut() async {
    // Local mode - no Firebase
  }

  /// Get last read page (returns null - use local Hive instead)
  Future<Map<String, dynamic>?> getLastReadPage() async {
    return null; // Use Hive local storage instead
  }

  /// Update last read page (does nothing - use local Hive instead)
  Future<void> updateLastReadPage(int page, {int? juzNumber}) async {
    // Local mode - use Hive instead
  }

  /// Sign in with email/password (stub)
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    // Local mode - no auth
  }

  /// Sign up with email/password (stub)
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Local mode - no auth
  }

  /// Sign in with Google (stub)
  Future<void> signInWithGoogle() async {
    // Local mode - no Google Sign In
  }
}
