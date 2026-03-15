import 'package:flutter/material.dart';

class AppPallete {
  static const Color backgroundColor = Colors.white;
  static const Color surface = Color(0xFFF8F8F8);
  static const Color gradient1 = Color.fromRGBO(187, 63, 221, 1);
  static const Color gradient2 = Color.fromRGBO(251, 109, 169, 1);
  static const Color gradient3 = Color.fromRGBO(255, 159, 124, 1);
  static const Color borderColor = Color.fromRGBO(52, 51, 67, 1);
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static const Color errorColor = Colors.redAccent;
  static const Color transparentColor = Colors.transparent;
  static const Color mainRed = Color.fromARGB(255, 255, 97, 97);

  static const Map<String, Color> mealColors = {
    'Breakfast': Color(0xFFFFA000),  // amber
    'Lunch': Color(0xFF1976D2),      // blue
    'Dinner': Color(0xFF6A1B9A),     // deepPurple
    'Brunch': Color(0xFF00897B),     // teal
    'All': Color(0xFFFF6161),        // mainRed
  };

  static const Map<String, List<Color>> diningHallGradients = {
    '251 North': [Color(0xFFFF6161), Color(0xFFFF8A65)],
    'Yahentamitsi': [Color(0xFF1565C0), Color(0xFF42A5F5)],
    'South': [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    'All': [Color(0xFF37474F), Color(0xFF78909C)],
  };

  static const Map<String, String> hallImages = {
    '251 North': 'assets/images/251_North_Tables.jpg',
    'Yahentamitsi': 'assets/images/Yahetamitsi_Dining_Hall.jpg',
    'South': 'assets/images/South_Dining_Hall.jpg',
    'All': 'assets/images/random_food.jpg',
  };

  static String hallImage(List<String>? halls) {
    if (halls == null || halls.isEmpty) return hallImages['All']!;
    return hallImages[halls.first] ?? hallImages['All']!;
  }

  static String hallDisplayName(List<String>? halls) {
    if (halls == null || halls.isEmpty) return 'All Halls';
    switch (halls.first) {
      case '251 North': return '251 North';
      case 'Yahentamitsi': return 'Yahentamitsi';
      case 'South': return 'South Campus';
      default: return halls.first;
    }
  }

  static List<Color> hallGradient(List<String>? halls) {
    if (halls == null || halls.isEmpty) return diningHallGradients['All']!;
    return diningHallGradients[halls.first] ?? diningHallGradients['All']!;
  }
}
