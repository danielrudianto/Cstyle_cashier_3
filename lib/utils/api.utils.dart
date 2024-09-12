import 'package:dio/dio.dart';

class ApiUtils {
  final Dio _dio;

  // final String baseURL = "https://api.cstyle.cloud/";

  // ApiUtils() : _dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:5000/"));
  ApiUtils()
      : _dio = Dio(BaseOptions(baseUrl: "https://service.cstyle.cloud/"));

  Future<dynamic> getRequest(
    String endpoint,
    Map<String, dynamic>? queryParams,
    Options? options,
  ) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: options,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> data,
    Options? options,
  ) async {
    try {
      final response = await _dio.post(endpoint, data: data, options: options);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response);
    }
  }
}
