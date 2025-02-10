import 'package:flutter/material.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/dining_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => const StartPage(),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      textStyle: const TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.bold,
      ),
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DiningPage(diningHall: ['251 North'])),
                ),
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/images/251_North_Tables.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Center(
                    child: Text(
                      '251 North',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DiningPage(diningHall: ['Yahentamitsi'])),
                ),
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/images/Yahetamitsi_Dining_Hall.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Yahetamitsi',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DiningPage(diningHall: ['South Campus'])),
                ),
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/images/South_Dining_Hall.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Center(
                    child: Text(
                      'South',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DiningPage(diningHall: [
                            '251 North',
                            'South Campus',
                            'Yahentamitsi'
                          ])),
                ),
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/images/random_food.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Browse',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
