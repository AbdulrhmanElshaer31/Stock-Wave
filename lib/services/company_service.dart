import 'package:stock_wave/models/news/news_model.dart';
import 'package:stock_wave/models/company/company_profile_model.dart';
import 'package:stock_wave/models/api_response/api_response.dart';
import 'package:stock_wave/services/finnhub_api_service.dart';

class CompanyService {
  final FinnhubApiService _api = FinnhubApiService();

  Future<ApiResponse<List<Newsmodel>>> getCompNews({
    required String symbol,
  }) async {
    final response = await _api.getCompanyNews(symbol: symbol);

    if (response.error != null) {
      return ApiResponse.error(
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = response.data;
    final List<Newsmodel> newsList = data
        .map((items) => Newsmodel.fromJson(items))
        .toList();
    return ApiResponse.success(data: newsList, statusCode: response.statusCode);
  }

  Future<ApiResponse<CompanyProfileModel>> getCompanyProfile({
    required String symbol,
  }) async {
    final response = await _api.getCompanyProfile(symbol: symbol);

    if (response.error != null) {
      return ApiResponse.error(
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> data = response.data;
    final profile = CompanyProfileModel.fromJson(data);
    return ApiResponse.success(data: profile, statusCode: response.statusCode);
  }
}
