// contains metrics - recommindation - Market Status
import 'finnhub_api_service.dart';
import 'package:stock_wave/models/api_response/api_response.dart';
import 'package:stock_wave/models/stock/recommendation_model.dart';
import 'package:stock_wave/models/stock/metrics_model.dart';
import 'package:stock_wave/models/stock/market_status_model.dart';

class StockService {
  final FinnhubApiService _api = FinnhubApiService();

  //recommindation
  Future<ApiResponse<List<dynamic>>> getRecmdtions({
    required String symbol,
  }) async {
    final recmditions = await _api.getRecommendation(symbol: symbol);
    if (recmditions.error != null) {
      return ApiResponse.error(
        error: recmditions.error,
        statusCode: recmditions.statusCode,
      );
    } else {
      final List<dynamic> data = recmditions.data;
      final List<RecommendationModel> recmditionsList = data
          .map((items) => RecommendationModel.fromJson(items))
          .toList();
      return ApiResponse.success(
        data: recmditionsList,
        statusCode: recmditions.statusCode,
      );
    }
  }

  //metrics

  Future<ApiResponse<List<dynamic>>> getMtrcs({
    required String metric,
    required String symbol,
  }) async {
    final mtrcs = await _api.getMetrics(metric: metric, symbol: symbol);
    if (mtrcs.error != null) {
      return ApiResponse.error(
        error: mtrcs.error,
        statusCode: mtrcs.statusCode,
      );
    } else {
      final List<dynamic> data = mtrcs.data;
      final List<MetricsModel> mtrcsList = data
          .map((items) => MetricsModel.fromJson(items))
          .toList();
      return ApiResponse.success(data: mtrcsList, statusCode: mtrcs.statusCode);
    }
  }

  //Market-Status
  Future<ApiResponse<List<dynamic>>> marketStatus({
    required String exchange,
  }) async {
    final marketsts = await _api.getMarketStatus(exchange: exchange);
    if (marketsts.error != null) {
      return ApiResponse.error(
        error: marketsts.error,
        statusCode: marketsts.statusCode,
      );
    } else {
      final List<dynamic> data = marketsts.data;
      final List<MarketStatusModel> marketStatusList = data
          .map((items) => MarketStatusModel.fromJson(items))
          .toList();
      return ApiResponse.success(
        data: marketStatusList,
        statusCode: marketsts.statusCode,
      );
    }
  }
}
