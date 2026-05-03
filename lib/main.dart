import 'package:flutter/material.dart';
import 'config/app_colors.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const IronAppDelivery());
}

class IronAppDelivery extends StatelessWidget {
  const IronAppDelivery({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IronApp Rider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      // Route to dashboard if already signed in, otherwise show login.
      home: AuthService.isSignedIn
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
