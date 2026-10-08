import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/api_service.dart';
import '../../data/models/story_model.dart';
import '../../widgets/orange_button.dart';

class StoryLoadingScreen extends StatefulWidget {
  const StoryLoadingScreen({super.key});

  @override
  State<StoryLoadingScreen> createState() => _StoryLoadingScreenState();
}

class _StoryLoadingScreenState extends State<StoryLoadingScreen> {
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final cq = context.read<CourageQuestState>();
    final uid = cq.userId;
    if (uid == null) {
      setState(() {
        _loading = false;
        _error = 'Not signed in';
      });
      return;
    }
    final can = await ApiService.getJson('/api/story/can_generate/$uid');
    if (can['can_generate'] != true) {
      setState(() {
        _loading = false;
        _error = 'You already read your story today! Come back tomorrow for a new adventure 🌟';
      });
      return;
    }
    final gen = await ApiService.postJson('/api/story/generate', {'user_id': uid});
    if (gen['success'] == true) {
      final pagesRaw = gen['story_pages'];
      final pages = <StoryPageModel>[];
      if (pagesRaw is List) {
        for (final p in pagesRaw) {
          if (p is Map) {
            pages.add(StoryPageModel.fromJson(Map<String, dynamic>.from(p)));
          }
        }
      }
      final audio = (gen['audio_url'] ?? '') as String;
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/story_reader',
        arguments: {'pages': pages, 'audio_url': audio},
      );
    } else {
      setState(() {
        _loading = false;
        _error = 'Could not generate your story';
      });
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _loading
                    ? const CircularProgressIndicator(color: AppColors.orange)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error ?? '', style: AppTextStyles.bodyText, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OrangeButton(
                            text: 'Back',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
