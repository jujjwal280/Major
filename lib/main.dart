import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:start1/auth/signup_screen.dart';
import 'package:start1/screens/dashboard_screen.dart';
import 'package:start1/screens/profile_screen.dart';
import 'package:start1/screens/transactions_screen.dart';
import 'package:start1/ui/onboarding_screen.dart';
import 'package:start1/ui/splash_screen.dart';
import 'auth/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define named routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboard': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
