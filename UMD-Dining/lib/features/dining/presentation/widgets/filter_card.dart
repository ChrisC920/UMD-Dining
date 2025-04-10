import 'package:flutter/material.dart';

class FilterCard extends StatefulWidget {
  final Set<String> selectedAllergens;
  final Set<String> selectedMealTypes;
  final Set<String> selectedDietaryPreferences;
  final void Function(Set<String> allergens, Set<String> mealTypes, Set<String> dietaryPreferences) onApply;

  const FilterCard({
    super.key,
    required this.selectedAllergens,
    required this.selectedMealTypes,
    required this.selectedDietaryPreferences,
    required this.onApply,
  });

  @override
  State<FilterCard> createState() => _FilterCardState();
}

class _FilterCardState extends State<FilterCard> {
  late Set<String> selectedAllergens;
  late Set<String> selectedMealTypes;
  late Set<String> selectedDietaryPreferences;

  final List<String> allergens = [
    'Sesame',
    'Fish',
    'Nuts',
    'Shellfish',
    'Dairy',
    'Eggs',
    'Soy',
    'Gluten',
  ];

  final List<String> dietaryPreferences = [
    'Vegetarian',
    'Vegan',
    'Halal',
    'Smart Choice',
  ];

  final List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Brunch',
  ];

  @override
  void initState() {
    super.initState();
    selectedAllergens = Set.from(widget.selectedAllergens);
    selectedMealTypes = Set.from(widget.selectedMealTypes);
    selectedDietaryPreferences = Set.from(widget.selectedDietaryPreferences);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Filter Options',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Helvetica',
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_sharp,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            const Divider(height: 30, thickness: 1),

            // Meal Types
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Meals", style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mealTypes.map((meal) {
                final selected = selectedMealTypes.contains(meal);
                return ChoiceChip(
                  showCheckmark: false,
                  label: Text(
                    meal,
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: selected,
                  selectedColor: Colors.white, // Color when selected
                  backgroundColor: Colors.grey[900], // Color when not selected
                  onSelected: (_) {
                    setState(() {
                      selected ? selectedMealTypes.remove(meal) : selectedMealTypes.add(meal);
                      widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    // side: BorderSide(color: selected ? Colors.red : Colors.grey.shade400),
                  ),
                  elevation: 2,
                );
              }).toList(),
            ),

            // const SizedBox(height: 24),
            const Divider(height: 30, thickness: 1),
            // Allergens
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dietary Preferences",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              // runSpacing: 0,
              children: dietaryPreferences.map((dietaryPreference) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 32, // half width minus padding
                  child: CheckboxListTile(
                    title: Text(dietaryPreference),
                    value: selectedDietaryPreferences.contains(dietaryPreference),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedDietaryPreferences.add(dietaryPreference);
                        } else {
                          selectedDietaryPreferences.remove(dietaryPreference);
                        }
                        widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences);
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 30, thickness: 1),
            // Allergens
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Exclude items containing...",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              // runSpacing: 0,
              children: allergens.map((allergen) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 32, // half width minus padding
                  child: CheckboxListTile(
                    title: Text(allergen),
                    value: selectedAllergens.contains(allergen),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedAllergens.add(allergen);
                        } else {
                          selectedAllergens.remove(allergen);
                        }
                        widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences);
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 30, thickness: 1),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedAllergens.clear();
                      selectedMealTypes.clear();
                      selectedDietaryPreferences.clear();
                      widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences);
                    });
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
