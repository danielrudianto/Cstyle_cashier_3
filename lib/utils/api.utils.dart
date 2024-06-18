import 'package:dio/dio.dart';

class ApiUtils {
  final Dio _dio;

  final String baseURL = "http://127.0.0.1:5000/";
  // final String baseURL = "https://api.cstyle.cloud/";

  ApiUtils() : _dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:5000/"));

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<dynamic> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }
}
