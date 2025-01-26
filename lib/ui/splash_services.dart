import 'package:flutter/material.dart';
import 'package:start1/screens/dashboard_screen.dart';
import 'package:start1/ui/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashServices {
  Future<bool> isAuthenticated() async {
    // Check if there's a currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  void checkAuthentication(BuildContext context) async {
    // Delay for the splash screen duration
    await Future.delayed(const Duration(seconds: 3));

    // Check authentication status
    bool loggedIn = await isAuthenticated();

    // Navigate based on authentication status
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()), // Ensure 'const' here
      );
    }
  }
}
