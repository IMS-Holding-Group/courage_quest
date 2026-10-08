import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/api_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/gained_rewards_bar.dart';
import '../../widgets/orange_button.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool _editing = false;
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cq = context.read<CourageQuestState>();
    final u = cq.user;
    if (u == null) return;
    final body = <String, dynamic>{'user_id': u.id};
    if (_email.text.trim().isNotEmpty) body['email'] = _email.text.trim();
    if (_pass.text.isNotEmpty) body['password'] = _pass.text;
    await ApiService.putJson('/api/auth/update', body);
    await cq.loadUser(u.id);
    if (!context.mounted) return;
    setState(() {
      _editing = false;
      _pass.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = context.watch<CourageQuestState>().user;
    final name = u?.name ?? u?.username ?? '';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.lightButterYellow,
        body: Column(
          children: [
            GainedRewardsBar(stars: u?.stars ?? 0),
            _greenBar(context, name),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _editing
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(controller: _email, decoration: _d('New email'), style: AppTextStyles.bodyText),
                          const SizedBox(height: 12),
                          TextField(controller: _pass, obscureText: true, decoration: _d('New password'), style: AppTextStyles.bodyText),
                          const SizedBox(height: 16),
                          OrangeButton(text: 'Save', onPressed: _save),
                        ],
                      )
                    : ListView(
                        children: [
                          Text('Username: ${u?.username ?? ''}', style: AppTextStyles.bodyText),
                          const SizedBox(height: 8),
                          Text('Email: ${u?.email ?? ''}', style: AppTextStyles.bodyText),
                          const SizedBox(height: 8),
                          Text('Password: ••••••••', style: AppTextStyles.bodyText),
                          const SizedBox(height: 16),
                          OrangeButton(
                            text: 'Edit',
                            onPressed: () {
                              _email.text = u?.email ?? '';
                              setState(() => _editing = true);
                            },
                          ),
                        ],
                      ),
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

  Widget _greenBar(BuildContext context, String name) {
    return Container(
      width: double.infinity,
      color: AppColors.darkGreen,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(child: Text(name, style: AppTextStyles.greenStripText, textAlign: TextAlign.center)),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  InputDecoration _d(String l) => InputDecoration(
        labelText: l,
        labelStyle: AppTextStyles.normalBrownText,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}
