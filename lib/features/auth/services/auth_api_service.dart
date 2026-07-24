import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fitmate_flutter/network/api_client.dart';

class AuthApiService {
  final Dio _dio = ApiClient.dio;

  /// 회원가입 API 호출 (POST /api/members/join), 성공 시 새로 생성된 회원의 id를 반환합니다.
  Future<String> join({
    required String email,
    required String password,
    required String checkPassword,
    required String name,
    required String birthDate, // yyyy-MM-dd 형식 문자열
    required double height,
  }) async {
    try {
      final response = await _dio.post(
        '/api/members/join',
        data: {
          'email': email,
          'password': password,
          'checkPassword': checkPassword,
          'name': name,
          'birthDate': birthDate,
          'height': height,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('서버 응답 에러: ${response.statusCode}');
      }

      final data = response.data;
      debugPrint('[AuthApiService.join] 응답 데이터: $data (${data.runtimeType})');

      // 서버가 문자열 메시지를 내려주는 경우 (현재 백엔드 응답 형태)
      if (data is String && data.isNotEmpty) return data;

      // 혹시 나중에 백엔드가 {"message": "..."} 형태로 바뀌는 경우도 대비
      if (data is Map<String, dynamic> && data['message'] is String) {
        return data['message'] as String;
      }

      // 그 외의 경우(바디가 비어있음 등)에도 statusCode가 200/201이면
      // 일단 성공으로 간주하고 기본 메시지를 돌려줌
      return '회원가입이 완료되었습니다.';
    } on DioException catch (e) {
      final serverMessage = ApiClient.extractErrorMessage(e);
      throw Exception(serverMessage ?? '회원가입에 실패했습니다.');
    } catch (e) {
      throw Exception('회원가입에 실패했습니다: $e');
    }
  }

  
}