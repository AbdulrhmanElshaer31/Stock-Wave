import 'package:stock_wave/models/api_response/api_response.dart';
import 'package:stock_wave/services/api_client.dart';
import 'package:stock_wave/utils/api_constans.dart';

class FinnhubApiService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<dynamic>> getQuote({String? symbol}) =>
      _client.get('${ApiConstans.quote}?symbol=$symbol');

  Future<ApiResponse<dynamic>> getNews({String? category}) =>
      _client.get('${ApiConstans.news}?category=$category');

  Future<ApiResponse<dynamic>> getCompanyNews({String? symbol}) => _client.get(
    '${ApiConstans.companyNews}?symbol=$symbol&from=2026-01-01&to=${DateTime.now().toString().split(' ')[0]}',
  );

  Future<ApiResponse<dynamic>> getSearchResult({String? query}) =>
      _client.get('${ApiConstans.search}?q=$query');

  Future<ApiResponse<dynamic>> getMarketStatus({String? exchange}) =>
      _client.get('${ApiConstans.marketStatus}?exchange=$exchange');

  Future<ApiResponse<dynamic>> getCompanyProfile({String? symbol}) =>
      _client.get('${ApiConstans.profile}?symbol=$symbol');

  Future<ApiResponse<dynamic>> getMetrics({
    String? symbol,
    String metric = 'all',
  }) => _client.get('${ApiConstans.metrics}?symbol=$symbol&metric=$metric');

  Future<ApiResponse<dynamic>> getRecommendation({String? symbol}) =>
      _client.get('${ApiConstans.recommendation}?symbol=$symbol');
}
