import 'package:flutter/material.dart';
import 'package:flutter_moving_background/components/moving_circle.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Constants {
  static const noConnectionErrorMessage = 'Not connected to a network!';
  static final supabase = Supabase.instance.client;
  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Brunch',
  ];

  static const List<String> databases = [
    'food_modified',
    'food_today',
    'food',
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
