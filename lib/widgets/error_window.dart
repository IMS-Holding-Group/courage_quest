import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'orange_button.dart';

class ErrorWindow extends StatelessWidget {
  const ErrorWindow({super.key, required this.message});

  final String message;

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
            Text(message, style: AppTextStyles.bodyText, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OrangeButton(text: 'OK', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
