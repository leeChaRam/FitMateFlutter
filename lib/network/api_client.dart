import 'package:dio/dio.dart';

// 앱 전체가 공유하는 Dio 인스턴스와 공통 유팅 
// baseUrl, timeout, interceptor(토큰 자동 첨부 등)를 여기서 한번만 하기! 

class ApiClient{
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5), 
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler){
        // TODO: 로그인 토큰이 생기면 여기서 헤더에 자동으로 붙이기 
        // final tokan = TokenStorage.getToken();
        // if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ),
  )
  // 디버깅용: 콘솔에 실제 요청/응답이 찍히는지 확인 (요청이 진짜 나가는지 확인용)
  // 문제 해결되면 이 인터셉터는 지우거나 kDebugMode 조건으로 감싸는 걸 추천합니다.
  ..interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  );

  // 서버가 내려준 DioException 응답에서 에러 메시지를 최대한 추출 
  // 프로젝트에 @ControllerAdvice로 정의된 에러 응답 포맷이 있다면 그 포맷에 맞게 수정 필요
  static String? extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String,dynamic>) {
      if (data['message'] is String) return data['meesage'] as String;
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        return (data['errors'] as List).map((e) => e.toString()).join('\n');
      }
    }
    return null;
  }
}