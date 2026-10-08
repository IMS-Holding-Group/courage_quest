import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.darkGreen),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _icon(0, 'assets/images/camera-icon.png'),
          _icon(1, 'assets/images/home-icon.png'),
          _icon(2, 'assets/images/profile-icon.png'),
        ],
      ),
    );
  }

  Widget _icon(int index, String asset) {
    final sel = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Opacity(
        opacity: sel ? 1 : 0.65,
        child: Image.asset(asset, width: 36, height: 36, fit: BoxFit.contain),
      ),
    );
  }
}
