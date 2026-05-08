
import 'package:stock_wave/models/search/search_item_model.dart';

class SearchResponseModel {
  final int count;
  final List<SearchItemModel> result;

  SearchResponseModel({required this.count, required this.result});

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchResponseModel(
      count: json['count'] ?? 0,
      result: (json['result'] as List)
          .map((item) => SearchItemModel.fromJson(item))
          .toList(),
    );
  }
}
