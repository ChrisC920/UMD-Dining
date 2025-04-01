import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_moving_background/enums/animation_types.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';
import 'package:gif/gif.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:umd_dining_refactor/core/common/widgets/loader.dart';
import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/features/auth/data/models/preferences_model.dart';
import 'package:umd_dining_refactor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/start_page.dart';

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
  final int _totalPages = 4;
  UserPreferences preferences = UserPreferences();
  int _currentPage = 0;
  int selectedAge = 18;
  late String userId;

  // Dining hall preferences
  bool likesYahentamitsi = false;
  bool likes251 = false;
  bool likesSouth = false;
  // Dietary restrictions and preferences
  bool allergicToSesame = false;
  bool isVegan = false;
  bool allergicToFish = false;
  bool allergicToNuts = false;
  bool allergicToShellfish = false;
  bool dairyFree = false;
  bool isHalal = false;
  bool eggFree = false;
  bool allergicToSoy = false;
  bool glutenFree = false;
  bool isVegetarian = false;
  // Cuisine preferences
  bool likesAmerican = false;
  bool likesMexican = false;
  bool likesItalian = false;
  bool likesAsian = false;
  bool likesIndian = false;
  bool likesMediterranean = false;
  bool likesAfrican = false;
  bool likesMiddleEastern = false;

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else if (_currentPage >= _totalPages) {
      // Handle page submission
      context.read<AuthBloc>().add(UpdateUserPreferencesEvent(userId: userId, preferences: preferences.preferences));
      Navigator.pushAndRemoveUntil(context, StartPage.route(), (route) => false);
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
        child: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
          if (state is AuthFailure) {
          } else if (state is AuthSuccess) {
            userId = state.user.id;
            Navigator.pushAndRemoveUntil(
              context,
              StartPage.route(),
              (route) => false,
            );
          }
        }, builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: Loader(),
            );
          }
          return Column(
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double width = constraints.maxWidth;
                          return Stack(
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
                                width: width * progress,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          );
                        },
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
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Text(
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
                          const SizedBox(height: 160),
                          Center(
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
                                    placeholder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    image: const AssetImage('assets/images/shine.gif'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "How old are you?",
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.black,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Helvetica',
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: Center(
                              child: NumberPicker(
                                itemWidth: 130,
                                value: selectedAge,
                                minValue: 0,
                                maxValue: 100,
                                step: 1,
                                itemHeight: 130,
                                axis: Axis.horizontal,
                                onChanged: (value) => setState(() => selectedAge = value),
                                textStyle: TextStyle(
                                  fontSize: 80,
                                  color: Colors.grey[600],
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Helvetica',
                                ),
                                selectedTextStyle: const TextStyle(
                                  fontSize: 80,
                                  color: Colors.black,
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Helvetica',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Which dining halls are your favorite?",
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.black,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Helvetica',
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  _diningHallCheckBox("251 Dining Hall", likes251, (bool? newValue) {
                                    setState(() {
                                      likes251 = newValue!;
                                      preferences = preferences.updatePreference('likes_251', likes251);
                                    });
                                  }),
                                  _diningHallCheckBox("Yahentamitsi Dining Hall", likesYahentamitsi, (bool? newValue) {
                                    setState(() {
                                      likesYahentamitsi = newValue!;
                                      preferences = preferences.updatePreference('likes_yahentamitsi', likesYahentamitsi);
                                    });
                                  }),
                                  _diningHallCheckBox("South Dining Hall", likesSouth, (bool? newValue) {
                                    setState(() {
                                      likesSouth = newValue!;
                                      preferences = preferences.updatePreference('likes_south', likesSouth);
                                    });
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Any dietary restrictions or preferences?",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Helvetica',
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  _dietaryCheckBox("Vegetarian", isVegetarian, (bool? newValue) {
                                    setState(() {
                                      isVegetarian = newValue!;
                                      preferences = preferences.updatePreference('is_vegetarian', isVegetarian);
                                    });
                                  }),
                                  _dietaryCheckBox("Vegan", isVegan, (bool? newValue) {
                                    setState(() {
                                      isVegan = newValue!;
                                      preferences = preferences.updatePreference('is_vegan', isVegan);
                                    });
                                  }),
                                  _dietaryCheckBox("Dairy Free", dairyFree, (bool? newValue) {
                                    setState(() {
                                      dairyFree = newValue!;
                                      preferences = preferences.updatePreference('dairy_free', dairyFree);
                                    });
                                  }),
                                  _dietaryCheckBox("Halal", isHalal, (bool? newValue) {
                                    setState(() {
                                      isHalal = newValue!;
                                      preferences = preferences.updatePreference('is_halal', isHalal);
                                    });
                                  }),
                                  _dietaryCheckBox("Gluten Free", glutenFree, (bool? newValue) {
                                    setState(() {
                                      glutenFree = newValue!;
                                      preferences = preferences.updatePreference('gluten_free', glutenFree);
                                    });
                                  }),
                                  _dietaryCheckBox("Sesame Allergy", allergicToSesame, (bool? newValue) {
                                    setState(() {
                                      allergicToSesame = newValue!;
                                      preferences = preferences.updatePreference('allergic_to_sesame', allergicToSesame);
                                    });
                                  }),
                                  _dietaryCheckBox("Fish Allergy", allergicToFish, (bool? newValue) {
                                    setState(() {
                                      allergicToFish = newValue!;
                                      preferences = preferences.updatePreference('allergic_to_fish', allergicToFish);
                                    });
                                  }),
                                  _dietaryCheckBox("Nut Allergy", allergicToNuts, (bool? newValue) {
                                    setState(() {
                                      allergicToNuts = newValue!;
                                      preferences = preferences.updatePreference('allergic_to_nuts', allergicToNuts);
                                    });
                                  }),
                                  _dietaryCheckBox("Shellfish Allergy", allergicToShellfish, (bool? newValue) {
                                    setState(() {
                                      allergicToShellfish = newValue!;
                                      preferences = preferences.updatePreference('allergic_to_shellfish', allergicToShellfish);
                                    });
                                  }),
                                  _dietaryCheckBox("Egg Free", eggFree, (bool? newValue) {
                                    setState(() {
                                      eggFree = newValue!;
                                      preferences = preferences.updatePreference('egg_free', eggFree);
                                    });
                                  }),
                                  _dietaryCheckBox("Soy Allergy", allergicToSoy, (bool? newValue) {
                                    setState(() {
                                      allergicToSoy = newValue!;
                                      preferences = preferences.updatePreference('allergic_to_soy', allergicToSoy);
                                    });
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "What kind of cuisine do you like?",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Helvetica',
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  _dietaryCheckBox("American", likesAmerican, (bool? newValue) {
                                    setState(() => likesAmerican = newValue!);
                                  }),
                                  _dietaryCheckBox("Mexican", likesMexican, (bool? newValue) {
                                    setState(() => likesMexican = newValue!);
                                  }),
                                  _dietaryCheckBox("Italian", likesItalian, (bool? newValue) {
                                    setState(() => likesItalian = newValue!);
                                  }),
                                  _dietaryCheckBox("Asian", likesAsian, (bool? newValue) {
                                    setState(() => likesAsian = newValue!);
                                  }),
                                  _dietaryCheckBox("Indian", likesIndian, (bool? newValue) {
                                    setState(() => likesIndian = newValue!);
                                  }),
                                  _dietaryCheckBox("Mediterranean", likesMediterranean, (bool? newValue) {
                                    setState(() => likesMediterranean = newValue!);
                                  }),
                                  _dietaryCheckBox("African", likesAfrican, (bool? newValue) {
                                    setState(() => likesAfrican = newValue!);
                                  }),
                                  _dietaryCheckBox("Middle Eastern", likesMiddleEastern, (bool? newValue) {
                                    setState(() => likesMiddleEastern = newValue!);
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                    crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                    children: [
                      ElevatedButton(
                        onPressed: _currentPage <= _totalPages ? _nextPage : null, // Disable when on last page
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.black.withAlpha(150); // Custom disabled color
                              }
                              return _currentPage < _totalPages ? Colors.black : const Color.fromARGB(255, 226, 64, 64); // Normal or disabled color
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.white.withAlpha(50); // Custom text color when disabled
                              }
                              return Colors.white; // Normal text color
                            },
                          ),
                          minimumSize: WidgetStateProperty.all(
                            const Size(double.infinity, 60),
                          ),
                          shape: WidgetStateProperty.all(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(24)), // Rounded corners
                            ),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300), // Adjust for smoothness
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child); // Fade transition
                          },
                          child: Text(
                            _currentPage < _totalPages ? "Next" : "Continue",
                            key: ValueKey<String>(_currentPage < _totalPages ? "Next" : "Continue"), // Unique key for text change
                            style: const TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                                return Colors.white.withAlpha(150); // Custom disabled color
                              }
                              return Colors.grey.shade100; // Normal color
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.black.withAlpha(100); // Custom text color when disabled
                              }
                              return Colors.black; // Normal text color
                            },
                          ),
                          minimumSize: WidgetStateProperty.all(
                            const Size(double.infinity, 60),
                          ),
                          shape: WidgetStateProperty.all(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(24)), // Rounded corners
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  CheckboxListTile _diningHallCheckBox(String text, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      activeColor: Colors.black,
      checkColor: Colors.white,
      side: const BorderSide(color: Colors.black, width: 2),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          height: 1.2,
          fontWeight: FontWeight.bold,
          fontFamily: 'Helvetica',
          letterSpacing: 0.1,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  CheckboxListTile _dietaryCheckBox(String text, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4), // Reduce size

        activeColor: Colors.black,
        checkColor: Colors.white,
        side: const BorderSide(color: Colors.black, width: 2),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            height: 1.2,
            fontWeight: FontWeight.bold,
            fontFamily: 'Helvetica',
            letterSpacing: 0.1,
          ),
        ),
        value: value,
        onChanged: onChanged);
  }
}
