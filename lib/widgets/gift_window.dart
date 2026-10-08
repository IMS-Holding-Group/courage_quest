import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class GiftWindow extends StatelessWidget {
  const GiftWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.lightBeige,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).pop(true),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('×', style: TextStyle(fontSize: 28, color: AppColors.darkBrown, fontFamily: AppTextStyles.fontFamily)),
                  ),
                ),
              ],
            ),
            Text(
              'Welcome gift! 3 stars 🎁',
              style: AppTextStyles.pageTitle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
