import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterCard extends StatefulWidget {
  final Set<String> selectedAllergens;
  final Set<String> selectedMealTypes;
  final Set<String> selectedDietaryPreferences;
  final DateTime? selectedDate;
  final void Function(Set<String> allergens, Set<String> mealTypes, Set<String> dietaryPreferences, DateTime? selectedDate) onApply;

  const FilterCard({
    super.key,
    required this.selectedAllergens,
    required this.selectedMealTypes,
    required this.selectedDietaryPreferences,
    required this.selectedDate,
    required this.onApply,
  });

  @override
  State<FilterCard> createState() => _FilterCardState();
}

class _FilterCardState extends State<FilterCard> {
  late DateTime? selectedDate;
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
    selectedDate = widget.selectedDate;
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
            _cardHeader(context),
            const Divider(height: 30, thickness: 1),
            FilterCardTextLabel(text: "Meal"),
            const SizedBox(height: 8),
            _mealTypeOptions(),
            const Divider(height: 30, thickness: 1),
            FilterCardTextLabel(text: "Dietary Preferences"),
            _dietaryPreferencesOptions(context),
            const Divider(height: 30, thickness: 1),
            FilterCardTextLabel(text: "Exclude items containing..."),
            _allergenOptions(context),
            const Divider(height: 30, thickness: 1),
            FilterCardTextLabel(text: "Filter by Date"),
            _dateOptions(context),
            const Divider(height: 30, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _clearButton(),
                _applyButton(context),
              ],
            )
          ],
        ),
      ),
    );
  }

  ElevatedButton _applyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences, selectedDate);
        Navigator.pop(context);
      },
      child: const Text('Apply', style: TextStyle(fontSize: 16)),
    );
  }

  OutlinedButton _clearButton() {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedAllergens.clear();
          selectedMealTypes.clear();
          selectedDietaryPreferences.clear();
          selectedDate = null;
          widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences, selectedDate);
        });
      },
      child: const Text(
        'Clear',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Row _dateOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          selectedDate != null ? DateFormat('EEEE, MMMM d').format(selectedDate!) : 'No date selected',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Row(
          children: [
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2025, 4, 3),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: const Text("Choose Date", style: TextStyle(fontSize: 16)),
            ),
            if (selectedDate != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedDate = null;
                  });
                },
                child: const Text("Clear", style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ],
    );
  }

  Wrap _allergenOptions(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: allergens.map((allergen) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 32, // half width minus padding
          child: CheckboxListTile(
            title: Text(allergen, style: Theme.of(context).textTheme.titleMedium),
            value: selectedAllergens.contains(allergen),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedAllergens.add(allergen);
                } else {
                  selectedAllergens.remove(allergen);
                }
                widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences, selectedDate);
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }

  Wrap _dietaryPreferencesOptions(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: dietaryPreferences.map((dietaryPreference) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 32, // half width minus padding
          child: CheckboxListTile(
            title: Text(dietaryPreference, style: Theme.of(context).textTheme.titleMedium),
            value: selectedDietaryPreferences.contains(dietaryPreference),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedDietaryPreferences.add(dietaryPreference);
                } else {
                  selectedDietaryPreferences.remove(dietaryPreference);
                }
                widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences, selectedDate);
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }

  Wrap _mealTypeOptions() {
    return Wrap(
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
              fontSize: 16,
            ),
          ),
          selected: selected,
          selectedColor: Colors.white, // Color when selected
          onSelected: (_) {
            setState(() {
              selected ? selectedMealTypes.remove(meal) : selectedMealTypes.add(meal);
              widget.onApply(selectedAllergens, selectedMealTypes, selectedDietaryPreferences, selectedDate);
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        );
      }).toList(),
    );
  }

  Stack _cardHeader(BuildContext context) {
    return Stack(
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
    );
  }
}

class FilterCardTextLabel extends StatelessWidget {
  String text;
  FilterCardTextLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
