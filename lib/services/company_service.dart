// contains cmp news and cmp profile
import 'package:stock_wave/models/news/news_model.dart';
import 'package:stock_wave/models/company/company_profile_model.dart';
import 'package:stock_wave/models/api_response/api_response.dart';
import 'finnhub_api_service.dart';

class CompanyService {
  final  FinnhubApiService _api = FinnhubApiService();
  //Get Company News
  Future<ApiResponse<List<dynamic>>> getCompNews({
    required String symbol,
  }) async {
    final cmpNews = await _api.getCompanyNews(symbol: symbol);
    if (cmpNews.error != null) {
      return ApiResponse.error(
        error: cmpNews.error,
        statusCode: cmpNews.statusCode,
      );
    } else {
      final List<dynamic> data = cmpNews.data;
      final List<Newsmodel> cmpNewsList = data
          .map((items) => Newsmodel.fromJson(items))
          .toList();
      return ApiResponse.success(
        data: cmpNewsList,
        statusCode: cmpNews.statusCode,
      );
    }
  }

  Future<ApiResponse<List<dynamic>>> getCmpProfile({
    required String symbol,
  }) async {
    final cmpProfile = await _api.getCompanyProfile(symbol: symbol);
    if (cmpProfile.error != null) {
      return ApiResponse.error(
        error: cmpProfile.error,
        statusCode: cmpProfile.statusCode,
      );
    } else {
      final List<dynamic> data = cmpProfile.data;
      final List<CompanyProfileModel> cmpProfileList = data
          .map((items) => CompanyProfileModel.fromJson(items))
          .toList();
      return ApiResponse.success(
        data: cmpProfileList,
        statusCode: cmpProfile.statusCode,
      );
    }
  }
}
