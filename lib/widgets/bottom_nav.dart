// File: lib/widgets/bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart'; // IMPORT

class BottomNav extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabChange;

  const BottomNav({
    Key? key,
    required this.activeIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Symbols.map, // Material Symbols
                label: 'Map',
                index: 0,
                isActive: activeIndex == 0,
              ),
              _buildNavItem(
                icon: Symbols.favorite, // Material Symbols
                label: 'Favorites',
                index: 1,
                isActive: activeIndex == 1,
              ),
              _buildNavItem(
                icon: Symbols.person, // Material Symbols
                label: 'Profile',
                index: 2,
                isActive: activeIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTabChange(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.blue[600] : Colors.grey[500],
              size: 24,
              fill: isActive ? 1.0 : 0.0, // Filled when active!
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.blue[600] : Colors.grey[500],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
