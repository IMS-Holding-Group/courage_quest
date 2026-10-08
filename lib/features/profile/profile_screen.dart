import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/gained_rewards_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _iconForGender(String g) {
    if (g == 'female') return 'assets/images/girl-icon.png';
    return 'assets/images/boy-icon.png';
  }

  void _nav(int i, BuildContext context) {
    if (i == 0) Navigator.pushNamed(context, '/ar');
    if (i == 1) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    if (i == 2) {}
  }

  @override
  Widget build(BuildContext context) {
    final u = context.watch<CourageQuestState>().user;
    final name = u?.name ?? u?.username ?? '';
    final gender = u?.gender ?? 'male';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.lightButterYellow,
        body: Column(
          children: [
            GainedRewardsBar(stars: u?.stars ?? 0),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(child: Image.asset(_iconForGender(gender), width: 96, height: 96)),
                  Container(
                    width: double.infinity,
                    color: AppColors.darkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(name, style: AppTextStyles.greenStripText, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),
                  _tile(context, 'Account details', () => Navigator.pushNamed(context, '/account')),
                  _tile(context, 'Medical info', () => Navigator.pushNamed(context, '/medical_data')),
                  _tile(context, 'Rewards', () => Navigator.pushNamed(context, '/rewards')),
                  _tile(context, 'Progress report', () => Navigator.pushNamed(context, '/report')),
                ],
              ),
            ),
            BottomNavBar(currentIndex: 2, onTap: (i) => _nav(i, context)),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Text(title, style: AppTextStyles.bodyText),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.darkBrown),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
