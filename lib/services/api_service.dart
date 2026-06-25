import 'package:dio/dio.dart';
import 'package:fitmate_flutter/models/body_info.dart';

class ApiService{
  final Dio _dio = Dio(BaseOptions(
    // 💡 에뮬레이터면 10.0.2.2, 실기기(폰) 테스트나 웹이면 실제 백엔드 IP 주소를 적어주세요.
    baseUrl: 'http://localhost:8080', 
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // 최근 체성분 기록 리스트 가져오기 리퀘스트
  Future<List<BodyInfoModel>> getRescentBodyInfos(int memberId) async {
    try {
      // 주소창 뒤에 Query Parameter (?memberId=1) 형태로 전달 
      final response = await _dio.get(
        '/api/body-info/recent',
        queryParameters: {'memberId': memberId},
      );
      
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
}