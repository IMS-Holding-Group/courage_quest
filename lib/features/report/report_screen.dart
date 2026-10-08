import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/api_service.dart';
import '../../data/models/session_model.dart';
import '../../widgets/bottom_nav_bar.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic>? _data;
  List<SessionModel> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = context.read<CourageQuestState>().userId;
    if (id == null) return;
    final r = await ApiService.getJson('/api/report/$id');
    if (!mounted) return;
    final bad = (r['http_status'] as int? ?? 200) != 200;
    final err = (r['error'] ?? '').toString();
    if (bad) {
      final msg = err.isNotEmpty ? err : 'Could not load report';
      setState(() {
        _data = {
          'bravery_progress': msg,
          'emotional_wellbeing': msg,
          'growth_mindset': msg,
          'facing_fears': msg,
          'coping_skills': msg,
        };
        _sessions = [];
      });
      return;
    }
    final list = <SessionModel>[];
    final raw = r['sessions'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          list.add(SessionModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    setState(() {
      _data = r;
      _sessions = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.lightButterYellow,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.darkGreen,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text('Progress report', style: AppTextStyles.greenStripText, textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _box('Bravery progress', '${d?['bravery_progress'] ?? '-'}'),
                  _box('Emotional wellbeing', '${d?['emotional_wellbeing'] ?? '-'}'),
                  _box('Growth mindset', '${d?['growth_mindset'] ?? '-'}'),
                  _box('Facing fears', '${d?['facing_fears'] ?? '-'}'),
                  _box('Coping skills', '${d?['coping_skills'] ?? '-'}'),
                  const SizedBox(height: 16),
                  Text('Distress across sessions', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: _sessions.isEmpty
                        ? Center(child: Text('No sessions yet', style: AppTextStyles.bodyText))
                        : LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true),
                              minX: 0,
                              maxX: (_sessions.length - 1).toDouble().clamp(0, double.infinity),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (v, m) {
                                      final i = v.toInt();
                                      if (i < 0 || i >= _sessions.length) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          _sessions[i].sessionDate,
                                          style: AppTextStyles.normalBrownText.copyWith(fontSize: 10),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 36,
                                    getTitlesWidget: (v, m) => Text('${v.toInt()}', style: AppTextStyles.normalBrownText.copyWith(fontSize: 10)),
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (int i = 0; i < _sessions.length; i++)
                                      FlSpot(i.toDouble(), _sessions[i].distressIndex),
                                  ],
                                  color: AppColors.orange,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                              minY: 0,
                              maxY: 100,
                            ),
                          ),
                  ),
                ],
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

  Widget _box(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white.withOpacity(0.75), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.bodyText),
          ],
        ),
      ),
    );
  }
}
