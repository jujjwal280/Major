import 'package:flutter/material.dart';
import 'package:start1/ui/splash_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final SplashServices splashServices = SplashServices();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Call the isLogin method to handle navigation
    splashServices.isLogin(context);

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose of the animation controller to avoid memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9FE7F5), // Background color of splash screen
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 50), // Add spacing from top
            Center(
              child: FadeTransition(
                opacity: _animation,
                child: const Column(
                  children: [
                    Icon(Icons.security, size: 100, color: Color(0xFFF27F0C)),
                    SizedBox(height: 20),
                    Text('MoneyMinder',
                      style: TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF053F5C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF053F5C)), // Show progress indicator
                  SizedBox(height: 20),
                  Text('❤️ Made by',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF053F5C),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('TEAM DHANRAKSHAK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
