import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/background.png', fit: BoxFit.cover),
            Center(
              child: Image.asset('assets/images/panda.png', width: 220),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 220),
                  Text('Welcome to Courage Quest!', style: AppTextStyles.welcomeTitle, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text('Tap anywhere to begin', style: AppTextStyles.welcomeSubtitle, textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
