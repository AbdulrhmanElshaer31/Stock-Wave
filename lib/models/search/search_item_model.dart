class SearchItemModel {
  final String description;
  final String displaySymbol;
  final String symbol;
  final String type;

  SearchItemModel({
    required this.description,
    required this.displaySymbol,
    required this.symbol,
    required this.type,
  });

  factory SearchItemModel.fromJson(Map<String, dynamic> json) {
    return SearchItemModel(
      description: json['description'] ?? '',
      displaySymbol: json['displaySymbol'] ?? '',
      symbol: json["symbol"] ?? '',
      type: json['type'] ?? '',
    );
  }
}
