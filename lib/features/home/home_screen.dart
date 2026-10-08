import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/services/api_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/gained_rewards_bar.dart';
import '../../widgets/gift_window.dart';
import '../../widgets/orange_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _giftChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeGift());
  }

  Future<void> _maybeGift() async {
    if (_giftChecked) return;
    _giftChecked = true;
    final cq = context.read<CourageQuestState>();
    final st = cq.user;
    if (st == null) return;
    if (st.welcomeGiftReceived != 0) return;
    final ok = await showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => const GiftWindow());
    if (ok == true && mounted) {
      final r = await ApiService.postJson('/api/activity/gift', {'user_id': st.id});
      if (r['success'] == true && mounted) {
        final stars = (r['stars'] as num?)?.toInt() ?? st.stars;
        cq.setLocalStars(stars);
        await cq.loadUser(st.id);
      }
    }
  }

  void _nav(int i) {
    if (i == 0) Navigator.pushNamed(context, '/ar');
    if (i == 1) {}
    if (i == 2) Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<CourageQuestState>().user;
    final stars = st?.stars ?? 0;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Column(
          children: [
            GainedRewardsBar(stars: stars),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/background.png', fit: BoxFit.cover),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OrangeButton(
                            text: 'Get a story',
                            onPressed: () => Navigator.pushNamed(context, '/story_loading'),
                          ),
                          const SizedBox(height: 20),
                          OrangeButton(
                            text: 'Calm-down exercise',
                            onPressed: () => Navigator.pushNamed(context, '/emergency'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BottomNavBar(currentIndex: 1, onTap: _nav),
          ],
        ),
      ),
    );
  }
}
