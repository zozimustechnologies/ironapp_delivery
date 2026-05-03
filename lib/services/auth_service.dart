import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Handles phone-OTP authentication via Supabase Auth.
class AuthService {
  AuthService._();

  static SupabaseClient get _client => SupabaseService.client;

  /// The currently signed-in user, or null if not authenticated.
  static User? get currentUser => _client.auth.currentUser;

  static bool get isSignedIn => currentUser != null;

  /// Stream of auth state changes (signed in, signed out, token refreshed…).
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Sends a one-time passcode to [phone].
  /// [phone] must be in E.164 format, e.g. "+15551234567".
  static Future<void> sendOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  /// Verifies the [token] (OTP) for the given [phone].
  /// Throws [AuthException] on invalid / expired code.
  static Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
