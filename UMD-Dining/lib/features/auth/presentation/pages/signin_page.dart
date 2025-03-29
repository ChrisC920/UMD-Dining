import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_moving_background/enums/animation_types.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';
import 'package:gif/gif.dart';
import 'package:umd_dining_refactor/core/common/widgets/loader.dart';
import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:umd_dining_refactor/features/auth/presentation/pages/onboarding_page.dart';
import 'package:umd_dining_refactor/features/auth/presentation/widgets/apple_sign_in_button.dart';
import 'package:umd_dining_refactor/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:umd_dining_refactor/features/auth/presentation/widgets/horizontal_scroll.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/start_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SignInPage());
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  double _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController()
      ..addListener(() {
        setState(() {
          _currentPageIndex = _pageViewController.page ?? 0;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  void _updateCurrentPageIndex(int index) {
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MovingBackground(
        animationType: AnimationType.rain,
        backgroundColor: Colors.grey.shade100,
        circles: Constants.movingCircles,
        child: Stack(
          fit: StackFit.expand,
          children: [
            BackgroundCard(
                currentPageIndex: 0, onPageUpdate: _updateCurrentPageIndex),
            IgnorePointer(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageViewController,
                children: [
                  AnimatedOpacity(
                    opacity: _currentPageIndex == 0 ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    child: BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthFailure) {
                          // showSnackBar(context, state.message);
                        } else if (state is AuthSuccess) {
                          // Future.delayed(const Duration(seconds: 6), () {
                          //   _updateCurrentPageIndex(1);
                          // });

                          Navigator.pushAndRemoveUntil(
                            context,
                            StartPage.route(),
                            (route) => false,
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Loader();
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(45),
                                  color: Colors.transparent,
                                  // TODO: I want to preview the app here
                                ),
                                alignment: Alignment.center,
                                height: 350,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 140),
                                  child: Stack(
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
                                          placeholder: (context) =>
                                              const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          image: const AssetImage(
                                              'assets/images/shine.gif'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    height: 1.2,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Helvetica',
                                    letterSpacing: 0.1,
                                    color: Colors.black, // Default text color
                                  ),
                                  children: [
                                    TextSpan(text: 'Eat '),
                                    TextSpan(
                                      text: 'smarter',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 213, 80, 80),
                                      ),
                                    ),
                                    TextSpan(text: ' at '),
                                    TextSpan(
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 213, 80, 80),
                                        ),
                                        text: 'Maryland'),
                                    TextSpan(text: ' Dining Halls'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              textAlign: TextAlign.center,
                              'Explore all of the dining options at the University of Maryland',
                              style: TextStyle(
                                height: 1.5,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Helvetica',
                                letterSpacing: 0.1,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        );
                      },
                    ),
                  ),
                  const OnboardingPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 24, right: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            height: 1.5,
          ),
          children: [
            const TextSpan(
                text: 'By signing up, you have read and agree to our\n'),
            TextSpan(
              text: 'Terms of Use',
              style: const TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final url =
                      Uri.parse('https://www.youtube.com/watch?v=ZfAYK1AEI2g');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final url =
                      Uri.parse('https://www.youtube.com/watch?v=ZfAYK1AEI2g');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch ${url.toString()}';
                  }
                },
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundCard extends StatelessWidget {
  const BackgroundCard({
    super.key,
    required this.currentPageIndex,
    required this.onPageUpdate,
  });

  final double currentPageIndex;
  final void Function(int) onPageUpdate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: (currentPageIndex <= 1.6 ? 650 - currentPageIndex * 400 : 0),
        // top: currentPageIndex <= 1 ? 650 - currentPageIndex * 400 : 250,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(45),
              topRight: Radius.circular(45),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 100.0, sigmaY: 100.0), // Adjust blur strength
              child: Container(
                // height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade400
                      .withOpacity(0.3), // Adjust opacity for the glass effect
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
              ),
            ),
          ),

          // Only show sign-in buttons when currentPageIndex is 0
          if (currentPageIndex == 0)
            const AnimatedOpacity(
              opacity: 1,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutQuart,
              child: Column(
                children: [
                  SizedBox(height: 30),
                  GoogleSignInButton(),
                  SizedBox(height: 15),
                  AppleSignInButton(),
                  TermsAndConditionsText(),
                  SizedBox(height: 0),
                ],
              ),
            ),

          // Show page 1 content when currentPageIndex is 1
          if (currentPageIndex >= 1 && currentPageIndex < 2)
            AnimatedOpacity(
              opacity: 2 - currentPageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuart,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Text(
                      "Enter your age",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Helvetica',
                        letterSpacing: 0.1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.arrow_drop_down,
                            size: 100, color: Color.fromARGB(255, 56, 56, 56)),
                        Center(
                          child: HorizontalScroll(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(75),
                        backgroundColor: const Color.fromARGB(142, 0, 24, 57),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => onPageUpdate(2),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),

          if (currentPageIndex >= 2 && currentPageIndex < 3)
            AnimatedOpacity(
              opacity: 3 - currentPageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuart,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  ElevatedButton(
                      onPressed: () => onPageUpdate(1),
                      child: Container(
                        child: const Text("TEMP"),
                      ))
                ],
              ),
            ),
        ],
      ),
    );
  }
}
