import 'package:stock_wave/services/finnhub_api_service.dart';
import 'package:stock_wave/models/api_response/api_response.dart';
import 'package:stock_wave/models/search/search_response_model.dart';

class SearchService {
  final FinnhubApiService _api = FinnhubApiService();

  Future<ApiResponse<SearchResponseModel>> getSearchResultFN({
    required String? query,
  }) async {
    final response = await _api.getSearchResult(query: query);

    if (response.error != null) {
      return ApiResponse.error(
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> data = response.data;
    final searchResult = SearchResponseModel.fromJson(data);
    return ApiResponse.success(
      data: searchResult,
      statusCode: response.statusCode,
    );
  }
}
