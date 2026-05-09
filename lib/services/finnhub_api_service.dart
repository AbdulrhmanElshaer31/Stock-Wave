import 'package:stock_wave/models/api_response/api_response.dart';

import 'api_client.dart';
import 'package:stock_wave/utils/api_constans.dart';

class FinnhubApiService {
  final ApiClient _client = ApiClient();
  // Get Quote
  Future<ApiResponse<dynamic>> getQuote({String? symbol}) =>
      _client.get('${ApiConstans.quote}?symbol=$symbol');
  // Get News
  Future<ApiResponse<dynamic>> getNews({String? category}) =>
      _client.get('${ApiConstans.news}?category=$category');
  // Get Company News
  Future<ApiResponse<dynamic>> getCompanyNews({String? symbol}) => _client.get(
    '${ApiConstans.companyNews}'
    '?symbol=$symbol'
    '&from=2026-01-01'
    '&to=${DateTime.now().toString().split(' ')[0]}',
  );
  //Search
  Future<ApiResponse<dynamic>> getSearchResult({String? query}) =>
      _client.get('${ApiConstans.search}?q=$query');
  // =======Stock=======
  // Get Market Status
  Future<ApiResponse<dynamic>> getMarketStatus({String? exchange}) =>
      _client.get('${ApiConstans.marketStatus}?exchange=$exchange');
  //Get Company Profile
  Future<ApiResponse<dynamic>> getCompanyProfile({String? symbol}) =>
      _client.get("${ApiConstans.profile}?symbol=$symbol");
  //Get Metrics
  Future<ApiResponse<dynamic>> getMetrics({
    String? symbol,
    String metric = 'all',
  }) => _client.get('${ApiConstans.metrics}?symbol=$symbol&metric=$metric');
  //Get recommendation
  Future<ApiResponse<dynamic>> getRecommendation({String? symbol}) =>
      _client.get("${ApiConstans.recommendation}?symbol=$symbol");
}

void main() async {
  FinnhubApiService test = FinnhubApiService();

  final companyNews = await test.getRecommendation(symbol: "AAPL");

  print(companyNews);
}
