class MetricsModel {
  final double high;
  final double low;
  final double marketCapitalization;
  final double peNormalizedAnnual;
  final double epsNormalizedAnnual;
  final double beta;

  MetricsModel({
    required this.high,
    required this.low,
    required this.marketCapitalization,
    required this.peNormalizedAnnual,
    required this.epsNormalizedAnnual,
    required this.beta,
  });

  factory MetricsModel.fromJson(Map<String, dynamic> json) {
    final metric = json['metric'] ?? json;

    return MetricsModel(
      high: (metric['52WeekHigh'] ?? 0).toDouble(),
      low: (metric['52WeekLow'] ?? 0).toDouble(),
      marketCapitalization: (metric['marketCapitalization'] ?? 0).toDouble(),
      peNormalizedAnnual: (metric['peNormalizedAnnual'] ?? 0).toDouble(),
      epsNormalizedAnnual: (metric['epsNormalizedAnnual'] ?? 0).toDouble(),
      beta: (metric['beta'] ?? 0).toDouble(),
    );
  }
}