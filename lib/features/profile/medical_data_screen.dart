import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/legacy_profile_display.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/gained_rewards_bar.dart';

class MedicalDataScreen extends StatelessWidget {
  const MedicalDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = context.watch<CourageQuestState>().user;
    final name = u?.name ?? u?.username ?? '';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.lightButterYellow,
        body: Column(
          children: [
            GainedRewardsBar(stars: u?.stars ?? 0),
            Container(
              width: double.infinity,
              color: AppColors.darkGreen,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(child: Text(name, style: AppTextStyles.greenStripText, textAlign: TextAlign.center)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Age: ${u?.age ?? '-'}', style: AppTextStyles.bodyText),
                  const SizedBox(height: 8),
                  Text('OCD type: ${u?.ocdType ?? '-'}', style: AppTextStyles.bodyText),
                  const SizedBox(height: 8),
                  Text('Anxiety level: ${LegacyProfileDisplay.anxiety(u?.anxietyLevel)}', style: AppTextStyles.bodyText),
                  const SizedBox(height: 12),
                  Material(
                    color: AppColors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pushNamed(context, '/compulsive'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text('Compulsive behaviors', style: AppTextStyles.bodyText),
                            const Spacer(),
                            const Icon(Icons.chevron_right, color: AppColors.darkBrown),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BottomNavBar(
              currentIndex: 2,
              onTap: (i) {
                if (i == 1) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                if (i == 0) Navigator.pushNamed(context, '/ar');
              },
            ),
          ],
        ),
      ),
    );
  }
}
