import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/api_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/error_window.dart';
import '../../widgets/gained_rewards_bar.dart';
import '../../widgets/item_window.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  Future<void> _sync() async {
    final cq = context.read<CourageQuestState>();
    final id = cq.userId;
    if (id == null) return;
    final r = await ApiService.getJson('/api/rewards/$id');
    if (r['success'] == true && mounted) {
      final unl = (r['unlocked_items'] as List).map((e) => e.toString()).toList();
      cq.setUnlocked(unl);
      cq.setEquipped(r['equipped_item'] as String?);
      cq.setLocalStars((r['stars'] as num?)?.toInt() ?? 0);
    }
  }

  String _archieAsset(String? eq) {
    switch (eq) {
      case 'wand':
        return 'assets/images/Archie_with_wand.png';
      case 'bow':
        return 'assets/images/Archie_with_bow.png';
      case 'crown':
        return 'assets/images/Archie_with_crown.png';
      default:
        return 'assets/images/panda2.png';
    }
  }

  Future<void> _tapBox(String item, int price, String img, bool unlocked, bool equipped) async {
    final st = context.read<CourageQuestState>().user;
    final cq = context.read<CourageQuestState>();
    if (st == null) return;
    if (!unlocked) {
      if (st.stars < price) {
        await showDialog(context: context, builder: (_) => const ErrorWindow(message: 'Not enough stars. Read a story to earn more!'));
        return;
      }
      final r = await ApiService.postJson('/api/rewards/unlock', {'user_id': st.id, 'item': item});
      if (r['success'] == true && mounted) {
        await showDialog(
          context: context,
          builder: (_) => ItemWindow(message: 'Item unlocked! 🎉', imageAsset: img),
        );
        final rs = (r['remaining_stars'] as num?)?.toInt();
        if (!context.mounted) return;
        if (rs != null) cq.setLocalStars(rs);
        await _sync();
        setState(() {});
      }
      return;
    }
    if (!equipped) {
      await ApiService.postJson('/api/rewards/equip', {'user_id': st.id, 'item': item});
      cq.setEquipped(item);
      await cq.loadUser(st.id);
      if (!context.mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = context.watch<CourageQuestState>().user;
    final unlocked = u?.unlockedItems ?? [];
    final eq = u?.equippedItem;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Column(
          children: [
            GainedRewardsBar(stars: u?.stars ?? 0),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/background2.png', fit: BoxFit.cover),
                  SafeArea(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkBrown),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Image.asset(_archieAsset(eq), height: 160),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _box(
                                    context,
                                    item: 'wand',
                                    price: AppConstants.wandCost,
                                    unlocked: unlocked.contains('wand'),
                                    equipped: eq == 'wand',
                                    asset: 'assets/images/Wand.png',
                                  ),
                                  _box(
                                    context,
                                    item: 'bow',
                                    price: AppConstants.bowCost,
                                    unlocked: unlocked.contains('bow'),
                                    equipped: eq == 'bow',
                                    asset: 'assets/images/Bow.png',
                                  ),
                                  _box(
                                    context,
                                    item: 'crown',
                                    price: AppConstants.crownCost,
                                    unlocked: unlocked.contains('crown'),
                                    equipped: eq == 'crown',
                                    asset: 'assets/images/Crown.png',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _box(
    BuildContext context, {
    required String item,
    required int price,
    required bool unlocked,
    required bool equipped,
    required String asset,
  }) {
    Color bg;
    Widget? lock;
    if (!unlocked) {
      bg = AppColors.darkOrange;
      lock = Image.asset('assets/images/lock.png', width: 28, height: 28);
    } else if (equipped) {
      bg = AppColors.lightGreen;
      lock = null;
    } else {
      bg = AppColors.lightBeige;
      lock = null;
    }
    return GestureDetector(
      onTap: () => _tapBox(item, price, asset, unlocked, equipped),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            if (lock != null) lock,
            Image.asset(asset, height: 48),
            const SizedBox(height: 6),
            Text('$price', style: AppTextStyles.normalBrownText),
          ],
        ),
      ),
    );
  }
}
