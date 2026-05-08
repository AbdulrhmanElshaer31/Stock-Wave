class RecommendationModel {
  final double buy;
  final double hold;
  final String period;
  final double sell;
  final double strongBuy;
  final double strongSell;
  final String symbol;

  RecommendationModel({
    required this.buy,
    required this.hold,
    required this.period,
    required this.sell,
    required this.strongBuy,
    required this.strongSell,
    required this.symbol,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      buy: json['buy'].toDouble() ?? 0,
      hold: json['hold'].toDouble() ?? 0,
      period: json['period'] ?? '',
      sell: json['sell'] ?? 0,
      strongBuy: json['strongBuy'] ?? 0,
      strongSell: json['strongSell'] ?? 0,
      symbol: json['symbol'] ?? '',
    );
  }
}
