class AnalysisRecord {
  final DateTime date;
  final double overallScore;
  final double frizzScore;
  final double damageScore;
  final double dryScore;
  final List<String> imagePaths;
  final Map<String, String> recommendations;

  const AnalysisRecord({
    required this.date,
    required this.overallScore,
    required this.frizzScore,
    required this.damageScore,
    required this.dryScore,
    required this.imagePaths,
    required this.recommendations,
  });
}
