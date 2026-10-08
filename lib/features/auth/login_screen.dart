import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/api_service.dart';
import '../../widgets/orange_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _error = null);
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    final st = context.read<CourageQuestState>();
    final r = await ApiService.postJson('/api/auth/login', {
      'username': _userCtrl.text.trim(),
      'password': _passCtrl.text,
    });
    if (r['success'] == true) {
      final id = (r['user_id'] as num).toInt();
      await st.loadUser(id);
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final err = (r['error'] ?? '').toString();
      setState(() => _error = err.isEmpty ? 'Invalid username or password' : err);
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text('Welcome back!', style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _userCtrl,
                      decoration: _decoration('Username'),
                      style: AppTextStyles.bodyText,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: _decoration('Password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: AppColors.darkBrown),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account? ', style: AppTextStyles.normalBrownText),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/create_account'),
                          child: Text('Sign up!', style: AppTextStyles.linkText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OrangeButton(text: 'Log in', onPressed: _login),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: AppTextStyles.bodyText.copyWith(color: AppColors.darkOrange), textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.normalBrownText,
      filled: true,
      fillColor: AppColors.white.withOpacity(0.9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
