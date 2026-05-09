import 'package:stock_wave/models/api_response/api_response.dart';
import 'finnhub_api_service.dart';
import 'package:stock_wave/models/qoute/quote_model.dart';
class QouteService {
  final FinnhubApiService _api = FinnhubApiService();
  Future<ApiResponse<List<QuoteModel>>> getAllQoute({
    required String symbol,
  }) async {
    final qoute = await _api.getQuote(symbol: symbol);
    if (qoute.error != null) {
      return ApiResponse.error(
        error: qoute.error,
        statusCode: qoute.statusCode,
      );
    } else {
      final List<dynamic> data = qoute.data;

      final List<QuoteModel> qouteList = data
          .map((items) => QuoteModel.fromJson(items))
          .toList();
      return ApiResponse.success(data: qouteList, statusCode: qoute.statusCode);
    }
  }
}
