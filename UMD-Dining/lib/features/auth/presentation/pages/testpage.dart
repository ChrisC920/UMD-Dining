import 'package:flutter/material.dart';
import 'package:flutter_moving_background/enums/animation_types.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';
import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/features/auth/presentation/widgets/apple_sign_in_button.dart';
import 'package:umd_dining_refactor/features/auth/presentation/widgets/google_sign_in_button.dart';

class SmoothTransitionScreen extends StatefulWidget {
  const SmoothTransitionScreen({super.key});

  @override
  _SmoothTransitionScreenState createState() => _SmoothTransitionScreenState();
}

class _SmoothTransitionScreenState extends State<SmoothTransitionScreen> {
  bool _isLoggedIn = false; // Tracks whether user has logged in
  double _cardTopPosition = 500; // Initial position of the bottom card

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          MovingBackground(
            animationType: AnimationType.rain,
            backgroundColor: Colors.grey.shade100,
            circles: Constants.movingCircles,
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Logo and Text (fade-out on login)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _isLoggedIn ? 0 : 1,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/Logo.png', // Replace with your logo asset
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Eat ",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "smarter ",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "at ",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "Maryland\n",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "Dining Halls",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Explore all of the dining options at the\nUniversity of Maryland",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Card
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            top: _isLoggedIn ? screenHeight * 0.1 : _cardTopPosition,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _isLoggedIn ? 0.95 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: _isLoggedIn
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              // Add action for the button after transition
                            },
                            child: const Text("Continue"),
                          ),
                          const SizedBox(height: 30),
                        ],
                      )
                    : const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 30),
                          GoogleSignInButton(),
                          SizedBox(height: 15),
                          AppleSignInButton(),
                          SizedBox(height: 20),
                          Text(
                            "By signing up, you have read and agree to our\nTerms of Use and Privacy Policy",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simulates login and triggers the transition
  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
    });

    // Simulate delay for smooth transition
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _cardTopPosition = 100; // Move card to top
      });
    });
  }
}
