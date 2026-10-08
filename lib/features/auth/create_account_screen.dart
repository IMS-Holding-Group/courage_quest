import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../widgets/orange_button.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  bool get _len => Validators.isPasswordLengthValid(_passCtrl.text);
  bool get _up => Validators.hasUpper(_passCtrl.text);
  bool get _low => Validators.hasLower(_passCtrl.text);
  bool get _dig => Validators.hasDigit(_passCtrl.text);
  bool get _userOk => Validators.isUsernameValid(_userCtrl.text);
  bool get _emailOk => Validators.isEmailValid(_emailCtrl.text);
  bool get _match => _passCtrl.text == _confirmCtrl.text && _confirmCtrl.text.isNotEmpty;
  bool get _allOk => _userOk && _emailOk && _len && _up && _low && _dig && _match;

  void _next() {
    setState(() => _error = null);
    if (!_emailOk) {
      setState(() => _error = 'Please enter a valid email');
      return;
    }
    if (!_allOk || _userCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields and meet the password rules');
      return;
    }
    Navigator.pushNamed(
      context,
      '/medical',
      arguments: {
        'username': _userCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
      },
    );
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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
                    const SizedBox(height: 24),
                    Text('Create account', style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _userCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: _dec('Username (7–11 characters)'),
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: _dec('Email'),
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passCtrl,
                      onChanged: (_) => setState(() {}),
                      obscureText: true,
                      decoration: _dec('Password'),
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: 8),
                    _cond('• 8 to 12 characters', _len),
                    _cond('• At least one uppercase letter', _up),
                    _cond('• At least one lowercase letter', _low),
                    _cond('• At least one digit', _dig),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmCtrl,
                      onChanged: (_) => setState(() {}),
                      obscureText: true,
                      decoration: _dec('Confirm password'),
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: 24),
                    OrangeButton(text: 'Next', onPressed: _next, enabled: true),
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

  Widget _cond(String t, bool ok) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        t,
        style: AppTextStyles.conditionText.copyWith(color: ok ? AppColors.conditionGreen : AppColors.conditionOrange),
      ),
    );
  }

  InputDecoration _dec(String l) => InputDecoration(
        labelText: l,
        labelStyle: AppTextStyles.normalBrownText,
        filled: true,
        fillColor: AppColors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}
