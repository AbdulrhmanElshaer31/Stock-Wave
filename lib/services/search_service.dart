import 'finnhub_api_service.dart';
import 'package:stock_wave/models/api_response/api_response.dart';
import 'package:stock_wave/models/search/search_response_model.dart';

class SearchService {
  final FinnhubApiService _api = FinnhubApiService();
  Future<ApiResponse<List<dynamic>>> getSearchResultFN({
    required String? query,
  }) async {
    final search = await _api.getSearchResult(query: query);
    if (search.error != null) {
      return ApiResponse.error(
        error: search.error,
        statusCode: search.statusCode,
      );
    } else {
      final List<dynamic> data = search.data;
      final searchResultList = data
          .map((items) => SearchResponseModel.fromJson(items))
          .toList();
      return ApiResponse.success(
        data: searchResultList,
        statusCode: search.statusCode,
      );
    }
  }
}
