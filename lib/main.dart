import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'features/ar/ar_screen.dart';
import 'features/auth/create_account_screen.dart';
import 'features/auth/intro_video_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/medical_history_screen.dart';
import 'features/emergency/emergency_exercise_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/account_details_screen.dart';
import 'features/profile/compulsive_behavior_screen.dart';
import 'features/profile/medical_data_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/report/report_screen.dart';
import 'features/rewards/rewards_screen.dart';
import 'features/story/story_loading_screen.dart';
import 'features/story/story_questionnaire_screen.dart';
import 'features/story/story_reader_screen.dart';
import 'features/welcome/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CourageQuestState(),
      child: const CourageQuestApp(),
    ),
  );
}

class CourageQuestApp extends StatelessWidget {
  const CourageQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courage Quest',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: AppTextStyles.fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: AppTextStyles.fontFamily),
          bodyMedium: TextStyle(fontFamily: AppTextStyles.fontFamily),
          bodySmall: TextStyle(fontFamily: AppTextStyles.fontFamily),
          titleLarge: TextStyle(fontFamily: AppTextStyles.fontFamily),
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/create_account': (_) => const CreateAccountScreen(),
        '/medical': (_) => const MedicalHistoryScreen(),
        '/intro': (_) => const IntroVideoScreen(),
        '/home': (_) => const HomeScreen(),
        '/story_loading': (_) => const StoryLoadingScreen(),
        '/story_reader': (_) => const StoryReaderScreen(),
        '/story_questions': (_) => const StoryQuestionnaireScreen(),
        '/emergency': (_) => const EmergencyExerciseScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/account': (_) => const AccountDetailsScreen(),
        '/medical_data': (_) => const MedicalDataScreen(),
        '/compulsive': (_) => const CompulsiveBehaviorScreen(),
        '/rewards': (_) => const RewardsScreen(),
        '/report': (_) => const ReportScreen(),
        '/ar': (_) => const ArScreen(),
      },
    );
  }
}
