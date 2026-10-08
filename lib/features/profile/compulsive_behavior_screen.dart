import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/legacy_profile_display.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/gained_rewards_bar.dart';

class CompulsiveBehaviorScreen extends StatelessWidget {
  const CompulsiveBehaviorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = context.watch<CourageQuestState>().user;
    final name = u?.name ?? u?.username ?? '';
    final beh = u?.compulsiveBehaviors ?? [];
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
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: beh.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(LegacyProfileDisplay.behavior(beh[i]), style: AppTextStyles.bodyText),
                ),
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
