import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/story_model.dart';
import '../../widgets/orange_button.dart';

class StoryReaderScreen extends StatefulWidget {
  const StoryReaderScreen({super.key});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  late final PageController _pc;
  int _idx = 0;
  List<StoryPageModel> _pages = [];
  bool _inited = false;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['pages'] is List<StoryPageModel>) {
      _pages = List<StoryPageModel>.from(args['pages'] as List);
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_idx < _pages.length - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Navigator.pushReplacementNamed(context, '/story_questions');
    }
  }

  void _prev() {
    if (_idx > 0) {
      _pc.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return const Scaffold(body: Center(child: Text('No story yet', style: TextStyle(fontFamily: AppTextStyles.fontFamily))));
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/background.png', fit: BoxFit.cover),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Story book', style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _idx = i),
                    itemBuilder: (ctx, i) {
                      final p = _pages[i];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset('assets/images/${p.image}', height: 200, width: double.infinity, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 16),
                            Text(p.text, style: AppTextStyles.storyText, textAlign: TextAlign.start),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: OrangeButton(text: 'Previous', onPressed: _prev, enabled: _idx > 0)),
                      const SizedBox(width: 12),
                      Expanded(child: OrangeButton(text: _idx < _pages.length - 1 ? 'Next' : 'Finish reading', onPressed: _next)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
