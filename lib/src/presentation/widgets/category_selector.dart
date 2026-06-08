import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onCategorySelected(category),
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: isSelected 
                ? Theme.of(context).colorScheme.onPrimaryContainer 
                : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}
