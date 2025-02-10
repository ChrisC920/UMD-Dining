import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 110),
          const Padding(
            padding: EdgeInsets.only(
              left: 21,
            ),
            child: Text(
              'Let\'s Get Started',
              textAlign: TextAlign.left,
              style: TextStyle(
                height: 1.2,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica',
                letterSpacing: 0.1,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 21, right: 40),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                children: [
                  TextSpan(
                      text:
                          'We just need a few more things to cater your experience!')
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Expanded(
          //   child: Stack(
          //     children: [
          //       ClipRRect(
          //         borderRadius: const BorderRadius.only(
          //           topLeft: Radius.circular(45),
          //           topRight: Radius.circular(45),
          //         ),
          //         child: BackdropFilter(
          //           filter: ImageFilter.blur(
          //               sigmaX: 100.0, sigmaY: 100.0), // Adjust blur strength
          //           child: Container(
          //             decoration: BoxDecoration(
          //               color: Colors.red.shade400.withOpacity(
          //                   0.3), // Adjust opacity for the glass effect
          //               borderRadius: const BorderRadius.only(
          //                 topLeft: Radius.circular(45),
          //                 topRight: Radius.circular(45),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const Column(
          //         children: [
          //           SizedBox(height: 24),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
