// File: lib/widgets/category_selector.dart

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../models/poi.dart';

class CategorySelector extends StatelessWidget {
  final Category? selectedCategory;
  final Function(Category?) onCategoryChange;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'All',
        'category': null,
        'icon': Symbols.grid_view, // Changed
      },
      {
        'name': 'Food',
        'category': Category.food,
        'icon': Symbols.restaurant, // Changed
      },
      {
        'name': 'Attractions',
        'category': Category.attractions,
        'icon': Symbols.attractions, // Changed
      },
      {
        'name': 'Shopping',
        'category': Category.shopping,
        'icon': Symbols.shopping_bag, // Changed
      },
      {
        'name': 'Petrol',
        'category': Category.petrolStations,
        'icon': Symbols.local_gas_station, // Changed
      },
    ];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: categories.map((cat) {
            final isSelected = selectedCategory == cat['category'];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCategoryChange(cat['category'] as Category?),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[600] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
