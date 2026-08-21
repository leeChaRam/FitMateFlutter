import 'package:dio/dio.dart';
import 'package:fitmate_flutter/core/network/api_client.dart';
import 'package:fitmate_flutter/features/body_composition/models/body_info.dart';
import 'package:fitmate_flutter/features/body_composition/models/dashboard_response.dart';

class BodyApiService{
  // 💡 토큰 자동 첨부(Authorization 헤더)를 위해 공용 ApiClient.dio를 사용합니다.
  final Dio _dio = ApiClient.dio;

  // 최근 체성분 기록 리스트 가져오기 리퀘스트 (로그인한 사용자는 토큰으로 식별)
  Future<List<BodyInfoModel>> getRescentBodyInfos() async {
    try {
      final response = await _dio.get('/api/body-info/recent');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        // JSON 리스트를 가공하여 BodyInfoModel 리스트로 변환하여 리턴
        return data.map((json) => BodyInfoModel.fromJson(json)).toList();
      } else {
        throw Exception('서버 응답 에러: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('데이터를 불러오는데 실패했습니다: $e');
    }
  }

  //Dashboard 데이터 가져오기 request (로그인한 사용자는 토큰으로 식별)
  Future<DashboardResponse> getDashboard() async {
    final response = await _dio.get('/api/body-info/dashboard');
    return DashboardResponse.fromJson(response.data);
  }

  Future<void> postBodyInfo({
    required String measureDate, // yyyy-MM-dd
    required double weight,
    double? height,
    double? muscleMass,
    double? fatMass,
    String? memo,
  }) async {
    try{
      final response = await _dio.post(
        '/api/body-info',
        data: {
          'measureDate': measureDate,
          'weight': weight,
          'height': height,
          'muscleMass': muscleMass,
          'fatMass': fatMass,
          'memo': memo,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('서버 응답 에러: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('체성분 기록 저장에 실패했습니다: $e');
    }
  }
}
