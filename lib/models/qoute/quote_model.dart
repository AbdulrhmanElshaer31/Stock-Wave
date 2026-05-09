class QuoteModel {
  final double currentPrice;
  final double change;
  final double percentChange;
  final double highPriceOfTheDay;
  final double lowPriceOfTheDay;
  final double openPriceOfTheDay;
  final double previousClosePrice;

  QuoteModel({
    required this.currentPrice,
    required this.change,
    required this.percentChange,
    required this.highPriceOfTheDay,
    required this.lowPriceOfTheDay,
    required this.openPriceOfTheDay,
    required this.previousClosePrice,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      currentPrice: json['c'] ?? 0,
      change: json['d'] ?? 0,
      percentChange: json['dp'] ?? 0,
      highPriceOfTheDay: json['h'] ?? 0,
      lowPriceOfTheDay: json['l'] ?? 0,
      openPriceOfTheDay: json['o'] ?? 0,
      previousClosePrice: json['pc'] ?? 0,
    );
  }
}
