import 'package:stock_wave/models/api_response/api_response.dart';
import 'package:stock_wave/services/finnhub_api_service.dart';
import 'package:stock_wave/models/qoute/quote_model.dart';

class QouteService {
  final FinnhubApiService _api = FinnhubApiService();

  Future<ApiResponse<QuoteModel>> getQuote({required String symbol}) async {
    final response = await _api.getQuote(symbol: symbol);

    if (response.error != null) {
      return ApiResponse.error(
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> data = response.data;
    final quote = QuoteModel.fromJson(data);
    return ApiResponse.success(data: quote, statusCode: response.statusCode);
  }
}
