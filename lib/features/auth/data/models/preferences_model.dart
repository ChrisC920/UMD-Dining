class UserPreferences {
  late final Map<String, bool> preferences;

  UserPreferences({Map<String, bool>? initialPreferences})
      : preferences = initialPreferences ?? _defaultPreferences();

  /// Updates a preference and returns a new UserPreferences instance
  UserPreferences updatePreference(String key, bool value) {
    if (!preferences.containsKey(key)) {
      throw ArgumentError('Invalid preference key: $key');
    }

    final updatedPreferences = Map<String, bool>.from(preferences);
    updatedPreferences[key] = value;

    return UserPreferences(initialPreferences: updatedPreferences);
  }

  /// Static method to define default preferences
  static Map<String, bool> _defaultPreferences() {
    return {
      'likes_yahentamitsi': false,
      'likes_251': false,
      'likes_south': false,
      'allergic_to_sesame': false,
      'is_vegan': false,
      'allergic_to_fish': false,
      'allergic_to_nuts': false,
      'allergic_to_shellfish': false,
      'dairy_free': false,
      'is_halal': false,
      'egg_free': false,
      'allergic_to_soy': false,
      'gluten_free': false,
      'is_vegetarian': false,
      'likes_american': false,
      'likes_mexican': false,
      'likes_italian': false,
      'likes_asian': false,
      'likes_indian': false,
      'likes_mediterranean': false,
      'likes_african': false,
      'likes_middle_eastern': false,
    };
  }

  @override
  String toString() {
    return preferences.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
  }
}
