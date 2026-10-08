import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/api_service.dart';
import '../../widgets/orange_button.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final _nameCtrl = TextEditingController();
  DateTime? _birth;
  String? _gender;
  String? _ocd;
  String? _anxiety;
  final Map<String, bool> _beh = {
    'Hand washing / cleaning': false,
    'Repeating phrases': false,
    'Frequent reassurance seeking': false,
    'Avoiding places/people': false,
    'Checking things repeatedly': false,
    'Ordering / arranging': false,
  };
  String? _error;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(2015, 1, 1);
    final last = DateTime(now.year, now.month, now.day);
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2016, 6, 1),
      firstDate: first,
      lastDate: last,
      helpText: 'Select date of birth',
    );
    if (d != null) setState(() => _birth = d);
  }

  Future<void> _submit(Map<String, dynamic> creds) async {
    setState(() => _error = null);
    if (_nameCtrl.text.trim().isEmpty || _birth == null || _gender == null || _ocd == null || _anxiety == null) {
      setState(() => _error = 'Please fill in all required fields');
      return;
    }
    final selectedBeh = _beh.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedBeh.isEmpty) {
      setState(() => _error = 'Please choose at least one behavior');
      return;
    }
    final bd = '${_birth!.year.toString().padLeft(4, '0')}-${_birth!.month.toString().padLeft(2, '0')}-${_birth!.day.toString().padLeft(2, '0')}';
    final body = {
      'username': creds['username'],
      'email': creds['email'],
      'password': creds['password'],
      'name': _nameCtrl.text.trim(),
      'birth_date': bd,
      'gender': _gender,
      'ocd_type': _ocd,
      'anxiety_level': _anxiety,
      'compulsive_behaviors': selectedBeh,
    };
    final r = await ApiService.postJson('/api/auth/register', body);
    if (r['success'] == true) {
      final id = (r['user_id'] as num).toInt();
      if (!mounted) return;
      await context.read<CourageQuestState>().loadUser(id);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/intro', arguments: id);
    } else {
      setState(() => _error = (r['error'] ?? 'Could not register').toString());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creds = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (creds == null) {
      return const Scaffold(body: Center(child: Text('Error', style: TextStyle(fontFamily: AppTextStyles.fontFamily))));
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/background.png', fit: BoxFit.cover),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Let\'s meet our little adventurer!', style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameCtrl,
                      decoration: _dec('Name'),
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      tileColor: AppColors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(_birth == null ? 'Date of birth' : '${_birth!.year}-${_birth!.month}-${_birth!.day}', style: AppTextStyles.bodyText),
                      trailing: const Icon(Icons.calendar_today, color: AppColors.darkBrown),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 12),
                    Text('Gender', style: AppTextStyles.normalBrownText),
                    RadioListTile<String>(
                      title: Text('Male', style: AppTextStyles.bodyText),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    RadioListTile<String>(
                      title: Text('Female', style: AppTextStyles.bodyText),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _ocd,
                      decoration: _dec('OCD type'),
                      items: const [
                        DropdownMenuItem(value: 'Contamination OCD', child: Text('Contamination OCD', style: TextStyle(fontFamily: AppTextStyles.fontFamily))),
                        DropdownMenuItem(value: 'Symmetry OCD', child: Text('Symmetry OCD', style: TextStyle(fontFamily: AppTextStyles.fontFamily))),
                      ],
                      onChanged: (v) => setState(() => _ocd = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _anxiety,
                      decoration: _dec('Anxiety level'),
                      items: const [
                        DropdownMenuItem(value: 'Mild', child: Text('Mild', style: TextStyle(fontFamily: AppTextStyles.fontFamily))),
                        DropdownMenuItem(value: 'Moderate', child: Text('Moderate', style: TextStyle(fontFamily: AppTextStyles.fontFamily))),
                        DropdownMenuItem(value: 'High', child: Text('High', style: TextStyle(fontFamily: AppTextStyles.fontFamily))),
                      ],
                      onChanged: (v) => setState(() => _anxiety = v),
                    ),
                    const SizedBox(height: 12),
                    Text('Compulsive behaviors (you can pick more than one)', style: AppTextStyles.normalBrownText),
                    ..._beh.keys.map(
                      (k) => CheckboxListTile(
                        title: Text(k, style: AppTextStyles.bodyText),
                        value: _beh[k],
                        onChanged: (v) => setState(() => _beh[k] = v ?? false),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OrangeButton(text: 'Let\'s go!', onPressed: () => _submit(creds)),
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

  InputDecoration _dec(String l) => InputDecoration(
        labelText: l,
        labelStyle: AppTextStyles.normalBrownText,
        filled: true,
        fillColor: AppColors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}
