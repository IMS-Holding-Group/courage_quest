class SessionScorer {
  static double distressIndex(List<int> answers) {
    final total = answers.fold<int>(0, (a, b) => a + b);
    return double.parse(((total / 21.0) * 100).toStringAsFixed(2));
  }
}
