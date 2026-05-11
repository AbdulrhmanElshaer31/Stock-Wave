import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stock_wave/utils/api_constans.dart';
import 'package:stock_wave/models/api_response/api_response.dart';

class ApiClient {
  Future<ApiResponse<dynamic>> get(String endPoint) async {
    try {
      final request = await http.get(
        Uri.parse('${ApiConstans.url}$endPoint&token=${ApiConstans.apiKey}'),
      );

      if (request.statusCode == 200) {
        final data = jsonDecode(request.body);
        print('API Response: $data'); 

        return ApiResponse.success(data: data, statusCode: request.statusCode);
      } else {
        return ApiResponse.error(
          error: 'Failed to load data',
          statusCode: request.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(error: 'Network error');
    }
  }
}
