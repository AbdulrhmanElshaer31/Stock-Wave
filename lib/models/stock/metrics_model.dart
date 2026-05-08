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
    return MetricsModel(
      high: json['52WeekHigh'].toDouble() ?? 0,
      low: json['52WeekLow'].toDouble() ?? 0,
      marketCapitalization: json['marketCapitalization'].toDouble() ?? 0,
      peNormalizedAnnual: json['peNormalizedAnnual'].toDouble() ?? 0,
      epsNormalizedAnnual: json['epsNormalizedAnnual'].toDouble() ?? 0,
      beta: json['beta'].toDouble(),
    );
  }
}
