import 'package:dio/dio.dart';
import 'package:fitmate_flutter/core/network/api_client.dart';
import 'package:fitmate_flutter/features/home/models/home_response.dart';

class HomeApiService {
  // 💡 토큰 자동 첨부(Authorization 헤더)를 위해 공용 ApiClient.dio를 사용합니다.
  final Dio _dio = ApiClient.dio;

  // 홈 화면 데이터 가져오기 request (로그인한 사용자는 토큰으로 식별)
  Future<HomeResponse> getHome() async {
    try {
      final response = await _dio.get('/api/home');
      return HomeResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(e);
      throw Exception(message ?? '홈 화면 데이터를 불러오는데 실패했습니다.');
    }
  }

  // 목표 전체 교체 저장. goals에 담긴 지표들로 목표 목록 전체를 덮어쓰며,
  // 목록에 없는 기존 목표는 삭제된다. 빈 리스트를 보내면 모든 목표가 삭제된다.
  Future<void> saveGoals(List<GoalRequestItem> goals) async {
    try {
      final response = await _dio.post(
        '/api/goal',
        data: {'goals': goals.map((g) => g.toJson()).toList()},
      );
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('서버 응답 에러: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(e);
      throw Exception(message ?? '목표 저장에 실패했습니다.');
    }
  }
}
