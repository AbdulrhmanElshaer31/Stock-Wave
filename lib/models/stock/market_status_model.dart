class MarketStatusModel {
  final String exchange;
  final String holiday;
  final bool isOpen;
  final String session;
  final int cTimestamp;
  final String timezone;

  MarketStatusModel({
    required this.exchange,
    required this.holiday,
    required this.isOpen,
    required this.session,
    required this.cTimestamp,
    required this.timezone,
  });

  factory MarketStatusModel.fromJson(Map<String, dynamic> json) {
    return MarketStatusModel(
      exchange: json['exchange'],
      holiday: json['holiday'],
      isOpen: json['isOpen'],
      session: json['session'],
      cTimestamp: json['cTimestamp'],
      timezone: json['timezone'],
    );
  }
}
