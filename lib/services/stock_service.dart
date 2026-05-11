import 'package:stock_wave/services/finnhub_api_service.dart';
import 'package:stock_wave/models/api_response/api_response.dart';
import 'package:stock_wave/models/stock/recommendation_model.dart';
import 'package:stock_wave/models/stock/metrics_model.dart';
import 'package:stock_wave/models/stock/market_status_model.dart';

class StockService {
  final FinnhubApiService _api = FinnhubApiService();

  Future<ApiResponse<List<RecommendationModel>>> getRecmdtions({
    required String symbol,
  }) async {
    final response = await _api.getRecommendation(symbol: symbol);

    if (response.error != null) {
      return ApiResponse.error(
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = response.data;
    final List<RecommendationModel> list = data
        .map((items) => RecommendationModel.fromJson(items))
        .toList();
    return ApiResponse.success(data: list, statusCode: response.statusCode);
  }

  Future<ApiResponse<MetricsModel>> getMtrcs({
    required String metric,
    required String symbol,
  }) async {
    final response = await _api.getMetrics(metric: metric, symbol: symbol);

    if (response.error != null) {
      return ApiResponse.error(
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> data = response.data;
    final metrics = MetricsModel.fromJson(data);
    return ApiResponse.success(data: metrics, statusCode: response.statusCode);
  }

  Future<ApiResponse<MarketStatusModel>> marketStatus({
    required String exchange,
  }) async {
    final response = await _api.getMarketStatus(exchange: exchange);

    if (response.error != null) {
      return ApiResponse.error(
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> data = response.data;
    final status = MarketStatusModel.fromJson(data);
    return ApiResponse.success(data: status, statusCode: response.statusCode);
  }
}
