import 'package:dio/dio.dart';

class ApiUtils {
  final Dio _dio;

  // ApiUtils() : _dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:5000/"));
  ApiUtils()
      : _dio = Dio(BaseOptions(baseUrl: "https://service.cstyle.cloud/"));

  // e.response cuma keisi kalau server sempat balas (mis. 4xx/5xx).
  // Kalau gagal connect (timeout, DNS, refused, dll), e.response NULL,
  // jadi detail asli errornya harus diambil dari e.type / e.message / e.error,
  // bukan dari e.response (yang bakal cuma keluar "Exception" doang).
  Exception _describeError(DioException e) {
    if (e.response != null) {
      return Exception(
        "HTTP ${e.response?.statusCode}: ${e.response?.data}",
      );
    }
    return Exception(
      "${e.type}${e.message != null ? ' - ${e.message}' : ''}"
      "${e.error != null ? ' (${e.error})' : ''}",
    );
  }

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
      throw _describeError(e);
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
      throw _describeError(e);
    }
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _describeError(e);
    }
  }

  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _describeError(e);
    }
  }
}
