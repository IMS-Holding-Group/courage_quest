import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/api_service.dart';
import '../../widgets/orange_button.dart';

class EmergencyExerciseScreen extends StatefulWidget {
  const EmergencyExerciseScreen({super.key});

  @override
  State<EmergencyExerciseScreen> createState() => _EmergencyExerciseScreenState();
}

class _EmergencyExerciseScreenState extends State<EmergencyExerciseScreen> {
  int _page = 0;
  String? _error;
  bool _checking = true;
  bool _allowed = false;
  bool _rewarded = false;

  static const _pages = [
    'Every brave adventurer needs tools to face obstacles. These special exercises can help you feel calmer and stronger, and get you ready to keep your courageous journey going!',
    'Place your hands on your belly.\nTake a slow, deep breath in through your nose.\nFeel your belly grow like a balloon.\nNow breathe out slowly through your mouth.\nFeel the balloon shrink.\nLet’s do this 5 times together.',
    'Grab a pillow, blanket, or stuffed toy.\nHug it tightly.\nHold for 10 seconds.\nThen let go slowly.\nRepeat if you want.',
    'Look around and find:\n• 5 things you can see\n• 4 things you can touch\n• 3 things you can hear\n• 2 things you can smell\n• 1 thing you can taste',
  ];

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final uid = context.read<CourageQuestState>().userId;
    if (uid == null) {
      setState(() {
        _checking = false;
        _allowed = false;
      });
      return;
    }
    final r = await ApiService.getJson('/api/activity/can_exercise/$uid');
    setState(() {
      _checking = false;
      _allowed = r['can_exercise'] == true;
      if (!_allowed) _error = 'You finished today’s exercises! Nice work 🌟';
    });
  }

  Future<void> _finish() async {
    if (_rewarded) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final uid = context.read<CourageQuestState>().userId;
    if (uid == null) return;
    final st = context.read<CourageQuestState>();
    final r = await ApiService.postJson('/api/activity/exercise', {'user_id': uid});
    if (r['success'] == true) {
      _rewarded = true;
      final s = r['stars'];
      if (!context.mounted) return;
      if (s is num) {
        st.setLocalStars(s.toInt());
        await st.loadUser(uid);
      }
    } else {
      if (!context.mounted) return;
      setState(() => _error = 'You finished today’s exercises! Nice work 🌟');
      return;
    }
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/background.png', fit: BoxFit.cover),
            SafeArea(
              child: _checking
                  ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
                  : !_allowed
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_error ?? '', style: AppTextStyles.bodyText, textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                OrangeButton(text: 'Back', onPressed: () => Navigator.pop(context)),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.darkBrown),
                                  onPressed: _finish,
                                ),
                                const Spacer(),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(_pages[_page], style: AppTextStyles.storyText, textAlign: TextAlign.start),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OrangeButton(
                                      text: 'Previous',
                                      enabled: _page > 0,
                                      onPressed: _page > 0 ? () => setState(() => _page--) : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OrangeButton(
                                      text: _page < _pages.length - 1 ? 'Next' : 'Finish',
                                      onPressed: () {
                                        if (_page < _pages.length - 1) {
                                          setState(() => _page++);
                                        } else {
                                          _finish();
                                        }
                                      },
                                    ),
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
    );
  }
}
