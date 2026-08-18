import 'package:dio/dio.dart';
import 'package:fitmate_flutter/core/storage/token_storage.dart';

// 앱 전체가 공유하는 Dio 인스턴스와 공통 유틸.
// baseUrl, timeout, 토큰 자동 첨부(interceptor)를 여기서 한번만 설정하고,
// 각 도메인의 api_service(예: features/auth/services/auth_api_service.dart)는 이 Dio를 가져다 씀.

class ApiClient{
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        // 토큰이 만료/무효화되어 인증에 실패한 경우 로컬 토큰을 정리
        if (error.response?.statusCode == 401) {
          await TokenStorage.clearToken();
        }
        handler.next(error);
      },
    ),
  );
  // 서버가 내려준 DioException 응답에서 에러 메시지를 최대한 추출
  // 프로젝트에 @ControllerAdvice로 정의된 에러 응답 포맷이 있다면 그 포맷에 맞게 수정 필요
  static String? extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String,dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        return (data['errors'] as List).map((e) => e.toString()).join('\n');
      }
    }
    return null;
  }
}
