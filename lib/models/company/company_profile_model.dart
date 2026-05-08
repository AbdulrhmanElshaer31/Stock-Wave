class CompanyProfileModel {
  final String country;
  final String currency;
  final String estimateCurrency;
  final String exchange;
  final String finnhubIndustry;
  final String ipo;
  final String logo;
  final double marketCapitalization;
  final String name;
  final String phone;
  final double shareOutstanding;
  final String ticker;
  final String weburl;

  CompanyProfileModel({
    required this.country,
    required this.currency,
    required this.estimateCurrency,
    required this.exchange,
    required this.finnhubIndustry,
    required this.ipo,
    required this.logo,
    required this.marketCapitalization,
    required this.name,
    required this.phone,
    required this.shareOutstanding,
    required this.ticker,
    required this.weburl,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      country: json['country'] ?? '',
      currency: json['currency'] ?? '',
      estimateCurrency: json['estimateCurrency'] ?? '',
      exchange: json['exchange'] ?? '',
      finnhubIndustry: json['finnhubIndustry'] ?? '',
      ipo: json['ipo'] ?? '',
      logo: json['logo'] ?? '',
      marketCapitalization: json['marketCapitalization'].toDouble() ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      shareOutstanding: json['shareOutstanding'].toDouble() ?? 0,
      ticker: json['ticker'] ?? '',
      weburl: json['weburl'] ?? '',
    );
  }
}
