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

  // 프로필 사진 업로드/교체, 성공 시 서버가 준 새 이미지 URL을 반환한다.
  // (응답에 회원 정보 전체가 외지만 privacy 형식이 GET /me와 달라, 필요한 URL만 꺼냄)
  Future<String?> uploadProfileImage({
    required List<int> bytes,
    required String filename,
  }) async {
    try{
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = 
        await _dio.post('/api/members/me/profile-image', data: formData);
      final data = response.data;
      return data is Map<String, dynamic>
        ? data['profileImageUrl'] as String?
        : null;
    } on DioException catch (e) {
      final message = ApiClient.extractErrorMessage(e);
      throw Exception(message ?? '프로필 사진 업로드에 실패했습니다.');
    }
  }
}