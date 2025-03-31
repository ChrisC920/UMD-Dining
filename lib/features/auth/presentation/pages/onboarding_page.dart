import 'package:flutter/material.dart';
import 'package:flutter_moving_background/enums/animation_types.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';
import 'package:gif/gif.dart';
import 'package:umd_dining_refactor/core/constants/constants.dart';

class OnboardingPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const OnboardingPage(),
      );
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final int _totalPages = 3;
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _updateCurrentPageIndex(int index) {
    setState(() {
      _currentPage = index;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentPage) / _totalPages;

    return Scaffold(
      body: MovingBackground(
        animationType: AnimationType.rain,
        backgroundColor: Colors.grey.shade100,
        circles: Constants.movingCircles,
        child: Column(
          children: [
            const SizedBox(height: 60), // Adjust for safe area

            // Progress Bar with Back Arrow and Page Counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Back Arrow Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  // Animated Progress Bar
                  Expanded(
                    child: Stack(
                      children: [
                        // Background Bar
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Animated Progress Indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: 4,
                          width: MediaQuery.of(context).size.width *
                              progress *
                              0.8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Page Counter
                  Text(
                    "$_currentPage / $_totalPages",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Hevletica',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Let's get to know you!",
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.black,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Helvetica',
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "We just need to know a few things to get you started.",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[700],
                              height: 1.2,
                              letterSpacing: 1.2,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 160),
                        Stack(
                          children: [
                            Image.asset(
                              'assets/images/Logo.png',
                              width: 350,
                            ),
                            Positioned(
                              bottom: 70,
                              right: -10,
                              child: Gif(
                                height: 70,
                                fps: 15,
                                autostart: Autostart.loop,
                                placeholder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                image:
                                    const AssetImage('assets/images/shine.gif'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Center(
                      child: Text("Page 2", style: TextStyle(fontSize: 24))),
                  const Center(
                      child: Text("Page 3", style: TextStyle(fontSize: 24))),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center horizontally
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage < _totalPages
                          ? _nextPage
                          : null, // Disable when on last page
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.black
                                  .withAlpha(150); // Custom disabled color
                            }
                            return Colors.black; // Normal color
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.white.withAlpha(
                                  50); // Custom text color when disabled
                            }
                            return Colors.white; // Normal text color
                          },
                        ),
                        minimumSize: WidgetStateProperty.all(
                          const Size(double.infinity, 60),
                        ),
                        shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(24)), // Rounded corners
                          ),
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Space between buttons
                    ElevatedButton(
                      onPressed: _currentPage > 0 ? _prevPage : null,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.white
                                  .withAlpha(150); // Custom disabled color
                            }
                            return Colors.grey.shade100; // Normal color
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.black.withAlpha(
                                  100); // Custom text color when disabled
                            }
                            return Colors.black; // Normal text color
                          },
                        ),
                        minimumSize: WidgetStateProperty.all(
                          const Size(double.infinity, 60),
                        ),
                        shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(24)), // Rounded corners
                          ),
                        ),
                      ),
                      child: const Text(
                        "Previous",
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
