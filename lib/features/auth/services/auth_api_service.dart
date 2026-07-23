import 'package:dio/dio.dart';
import 'package:fitmate_flutter/network/api_client.dart';

class AuthApiService {
  final Dio _dio = ApiClient.dio;

  /// 회원가입 API 호출 (POST /api/members/join), 성공 시 새로 생성된 회원의 id를 반환합니다.
  Future<int> join({
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

      return response.data as int;
    } on DioException catch (e) {
      final serverMessage = ApiClient.extractErrorMessage(e);
      throw Exception(serverMessage ?? '회원가입에 실패했습니다.');
    } catch (e) {
      throw Exception('회원가입에 실패했습니다: $e');
    }
  }

  
}