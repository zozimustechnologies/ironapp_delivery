/// Supabase project credentials.
///
/// Replace the placeholder values with your project's URL and anon key.
/// Find them at: https://supabase.com → your project → Settings → API
///
/// ⚠️  Never commit real credentials to version control.
///     Use --dart-define or a secrets manager for production builds.
class SupabaseConfig {
  SupabaseConfig._();

  // TODO: replace with your Supabase project URL
  static const String url = 'https://YOUR_PROJECT_ID.supabase.co';

  // TODO: replace with your Supabase anon key
  static const String anonKey = 'YOUR_ANON_KEY';
}
