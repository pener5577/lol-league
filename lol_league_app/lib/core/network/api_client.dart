import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  String? _token;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  String? get token => _token;

  Future<ApiResponse> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> uploadFile(String endpoint, String filePath, String fieldName) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(endpoint, data: formData);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final String? token;
  final Map<String, dynamic>? user;
  final List<dynamic>? listData;
  final int? total;
  final bool? hasMore;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.token,
    this.user,
    this.listData,
    this.total,
    this.hasMore,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      token: json['token'],
      user: json['user'],
      listData: json['data'] is List ? json['data'] : null,
      total: json['total'],
      hasMore: json['hasMore'],
    );
  }

  factory ApiResponse.fromDioError(DioException e) {
    String message = '网络请求失败';
    if (e.type == DioExceptionType.connectionTimeout) {
      message = '连接超时，请检查网络';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = '服务器响应超时';
    } else if (e.response != null) {
      message = e.response?.data?['message'] ?? '请求失败';
    } else if (e.type == DioExceptionType.connectionError) {
      message = '无法连接服务器';
    }
    return ApiResponse(success: false, message: message);
  }
}
