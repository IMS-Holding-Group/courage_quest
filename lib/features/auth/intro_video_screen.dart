import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class IntroVideoScreen extends StatefulWidget {
  const IntroVideoScreen({super.key});

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  VideoPlayerController? _c;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.asset('assets/videos/intro_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _c!.play();
        _c!.addListener(_listener);
      });
  }

  void _listener() {
    final v = _c;
    if (v == null || !v.value.isInitialized) return;
    if (v.value.isCompleted) {
      _goHome();
    }
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _c?.removeListener(_listener);
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final raw = ModalRoute.of(context)!.settings.arguments;
    final userId = raw is int ? raw : (raw is num ? raw.toInt() : null);
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CourageQuestState>().loadUser(userId);
      });
    }
    return Scaffold(
      backgroundColor: AppColors.darkBrown,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_c != null && _c!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _c!.value.aspectRatio,
                child: VideoPlayer(_c!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: AppColors.orange)),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: _goHome,
                  child: Text('Skip video >', style: AppTextStyles.linkText.copyWith(color: AppColors.white, decoration: TextDecoration.none)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
