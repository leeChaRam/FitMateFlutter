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

   // 공개 설정 저장. 세 지표를 한 번에 PUT 하고, 서버가 되돌려준 최신 회원 정보를 반환한다.
  Future<MemberProfile> updatePrivacy({
    required PrivacyScope weight,
    required PrivacyScope muscle,
    required PrivacyScope fat,
  }) async {
    try {
      final response = await _dio.put(
        '/api/members/me/privacy',
        data: {
          'weightPrivacy': weight.value,
          'musclePrivacy': muscle.value,
          'fatPrivacy': fat.value,
        },
      );
      return MemberProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(e);
      throw Exception(message ?? '공개 설정 저장에 실패했습니다.');
    }
  }

  //이름 자기소개 수정 응답은 성공 여부만 확인 
  Future<void> updateBasicInfo({
    required String name,
    String? introduction,
  }) async {
    try {
      await _dio.put(
        '/api/members/me',
        data: {
          'name': name,
          'introduction': introduction,
        },
      );
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(e);
      throw Exception(message ?? '프로필 저장에 실패했습니다.');
    }
  }
}