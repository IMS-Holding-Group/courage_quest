import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class GainedRewardsBar extends StatelessWidget {
  const GainedRewardsBar({super.key, required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.darkGreen,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Center(
        child: Text(
          'Stars earned: $stars',
          style: AppTextStyles.greenStripText,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
