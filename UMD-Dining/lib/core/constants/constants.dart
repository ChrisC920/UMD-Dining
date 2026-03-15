import 'package:flutter/material.dart';
import 'package:flutter_moving_background/components/moving_circle.dart';

class Constants {
  static const noConnectionErrorMessage = 'Not connected to a network!';

  // Convex deployment URL — set via --dart-define=CONVEX_URL=... or update the defaultValue
  static const convexUrl = String.fromEnvironment(
    'CONVEX_URL',
    defaultValue: 'https://acoustic-ocelot-634.convex.cloud',
  );

  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Brunch',
  ];

  static const List<String> allergens = [
    'Contains Sesame',
    'Contains Fish',
    'Contains Nuts',
    'Contains Shellfish',
    'Contains Dairy',
    'Contains Eggs',
    'Contains Soy',
    'Contains Gluten',
    'Vegetarian',
    'Vegan',
    'Halal',
    'Smart Choice',
  ];

  static const List<MovingCircle> movingCircles = [
    MovingCircle(
      color: Color.fromARGB(112, 244, 67, 54),
      blurSigma: 100,
      radius: 1000,
    ),
    MovingCircle(
      color: Color.fromARGB(120, 255, 157, 130),
      blurSigma: 100,
      radius: 1000,
    ),
    MovingCircle(
      color: Color.fromARGB(134, 255, 235, 59),
      blurSigma: 100,
      radius: 1000,
    ),
    MovingCircle(
      color: Color.fromARGB(121, 255, 228, 93),
      blurSigma: 100,
      radius: 1000,
    ),
    MovingCircle(
      color: Color.fromARGB(112, 244, 67, 54),
      blurSigma: 100,
      radius: 1000,
    ),
    MovingCircle(
      color: Color.fromARGB(120, 255, 157, 130),
      blurSigma: 100,
      radius: 1000,
    ),
    MovingCircle(
      color: Color.fromARGB(134, 255, 235, 59),
      blurSigma: 100,
      radius: 1000,
    ),
    MovingCircle(
      color: Color.fromARGB(121, 255, 228, 93),
      blurSigma: 100,
      radius: 1000,
    ),
  ];
}
