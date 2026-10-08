import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'IBMPlexSansArabic';

  static const TextStyle welcomeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBrown,
  );

  static const TextStyle welcomeSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: AppColors.darkBrown,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBrown,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: AppColors.darkBrown,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle linkText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.orange,
    decoration: TextDecoration.underline,
  );

  static const TextStyle normalBrownText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.darkBrown,
  );

  static const TextStyle greenStripText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle rewardsBarText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkBrown,
  );

  static const TextStyle conditionText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
  );

  static const TextStyle storyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.8,
    color: AppColors.darkBrown,
  );
}
