import 'package:stock_wave/models/api_response/api_response.dart';
import 'finnhub_api_service.dart';
import 'package:stock_wave/models/news/news_model.dart';

class NewsService {
  final FinnhubApiService _api = FinnhubApiService();

  Future<ApiResponse<List<Newsmodel>>> getAllNews({String category = 'general'}) async {
    final news = await _api.getNews(category: category);

    if (news.error != null) {
      return ApiResponse.error(error: news.error!, statusCode: news.statusCode);
    } else {
      final List<dynamic> data = news.data;

      final List<Newsmodel> newsList = data
          .map((items) => Newsmodel.fromJson(items))
          .toList();
      return ApiResponse.success(data: newsList, statusCode: news.statusCode);
    }
  }
}
