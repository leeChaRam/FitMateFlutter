import 'package:dio/dio.dart';
import 'package:fitmate_flutter/core/network/api_client.dart';
import 'package:fitmate_flutter/features/profile/models/member_profile.dart';

class MemberApiService{
  // 토큰 자동 첨부(Authorization 헤더)를 위해 공용 ApiClient.dio를 사용
  final Dio _dio = ApiClient.dio;

  // 로그인한 회원 정보 조회 (토큰으로 식별)
  Future<MemberProfile> getMe() async {
    try{
      final response = await _dio.get('/api/members/me');
      return MemberProfile.fromJson(response.data as Map<String, dynamic>);
    }  on DioException catch (e) {
    final message = ApiClient.extractErrorMessage(e);
    throw Exception(message ?? '회원 정보를 불러오는데 실패했습니다.');
    }
  }
}