import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/api_service.dart';
import '../../widgets/orange_button.dart';

class StoryQuestionnaireScreen extends StatefulWidget {
  const StoryQuestionnaireScreen({super.key});

  @override
  State<StoryQuestionnaireScreen> createState() => _StoryQuestionnaireScreenState();
}

class _StoryQuestionnaireScreenState extends State<StoryQuestionnaireScreen> {
  final List<int?> _a = List<int?>.filled(8, null);

  bool get _complete => _a.every((e) => e != null);

  Future<void> _submit() async {
    final cq = context.read<CourageQuestState>();
    final uid = cq.userId;
    if (uid == null) return;
    final answers = _a.map((e) => e!).toList();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final r = await ApiService.postJson('/api/session/save', {
      'user_id': uid,
      'answers': answers,
      'date': date,
    });
    if (r['success'] == true && mounted) {
      final stars = r['stars'];
      if (stars is num) {
        cq.setLocalStars(stars.toInt());
      }
      await cq.loadUser(uid);
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('After the story', style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _q1(),
                        _q2(),
                        _q3(),
                        _q4(),
                        _q5(),
                        _q6(),
                        _q7(),
                        _q8(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: OrangeButton(text: 'Done', onPressed: _submit, enabled: _complete),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _block(String title, List<String> labels, List<int> scores, int qIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(labels.length, (i) {
            final s = scores[i];
            final sel = _a[qIndex] == s;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: sel ? AppColors.lightGreen : AppColors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _a[qIndex] = s),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(labels[i], style: AppTextStyles.bodyText),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _q1() => _block(
        '1) How do you feel right now?',
        ['Calm', 'A little worried', 'Very worried', 'Extremely worried'],
        [0, 1, 2, 3],
        0,
      );

  Widget _q2() => _block(
        '2) How big does your worry feel right now?',
        ['Tiny', 'Small', 'Medium', 'Big'],
        [0, 1, 2, 3],
        1,
      );

  Widget _q3() => _block(
        '3) Do you think the hero is like you?',
        ['Yes, a lot', 'A little', 'Not really'],
        [0, 1, 2],
        2,
      );

  Widget _q4() => _block(
        '4) Do you feel you can be brave like the hero?',
        ['Yes', 'Maybe a little', 'Not sure', 'Not right now'],
        [0, 1, 2, 3],
        3,
      );

  Widget _q5() => _block(
        '5) If worry shows up today, what will you do?',
        ['Face it bravely like the hero', 'Try a tiny step', 'Avoid it', 'Ask for help right away'],
        [0, 1, 2, 3],
        4,
      );

  Widget _q6() => _block(
        '6) When worry is strong, how hard is it to resist compulsions?',
        ['Easy', 'Kind of hard', 'Very hard', 'Nearly impossible'],
        [0, 1, 2, 3],
        5,
      );

  Widget _q7() => _block(
        '7) If you feel worried, will you use a calming exercise?',
        ['Yes', 'Maybe', 'Probably not'],
        [0, 1, 2],
        6,
      );

  Widget _q8() => _block(
        '8) Do you believe you can get better at handling worry over time?',
        ['Yes', 'Maybe', 'I don\'t know'],
        [0, 1, 2],
        7,
      );
}
