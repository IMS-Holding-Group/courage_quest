class SessionModel {
  SessionModel({
    required this.answers,
    required this.distressIndex,
    required this.sessionDate,
  });

  final List<int> answers;
  final double distressIndex;
  final String sessionDate;

  factory SessionModel.fromJson(Map<String, dynamic> j) {
    final a = j['answers'];
    return SessionModel(
      answers: (a is List) ? a.map((e) => int.tryParse(e.toString()) ?? 0).toList() : [],
      distressIndex: (j['distress_index'] is num)
          ? (j['distress_index'] as num).toDouble()
          : double.tryParse('${j['distress_index']}') ?? 0,
      sessionDate: (j['session_date'] ?? '') as String,
    );
  }
}
