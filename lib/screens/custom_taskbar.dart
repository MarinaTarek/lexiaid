import 'package:flutter/material.dart';

class CustomTaskBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomTaskBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });


  Color getColor(int index, bool isActive) {
    switch (index) {
      case 0: // HOME
        return isActive ? const Color(0xFF1565C0) : const Color(0xFF1976D2);
      case 1: // AI
        return isActive ? const Color(0xFF6A1B9A) : const Color(0xFF8E24AA);
      case 2: // PROGRESS
        return isActive ? const Color(0xFF2E7D32) : const Color(0xFF388E3C);
      case 3: // PROFILE
        return isActive ? const Color(0xFFF57C00) : const Color(0xFFEF6C00);
      default:
        return Colors.black45;
    }
  }

  Widget buildItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;
    Color color = getColor(index, isActive);

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFBBDEFB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildItem(Icons.home_rounded, "HOME", 0),
          buildItem(Icons.smart_toy_rounded, "AI", 1),
          buildItem(Icons.insights_rounded, "PROGRESS", 2),
          buildItem(Icons.person_rounded, "PROFILE", 3),
        ],
      ),
    );
  }
}