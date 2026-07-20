import 'package:dio/dio.dart';
import 'package:fitmate_flutter/models/body_info.dart';
import 'package:fitmate_flutter/models/dashboard_response.dart';

// ============================================================
// ApiService
// ------------------------------------------------------------
// 백엔드 개발 관점으로 비유하면: 이 클래스는 프론트엔드에서
// 쓰는 "HTTP Client Wrapper" 혹은 백엔드의 Feign Client / RestTemplate
// 래퍼 클래스와 비슷한 역할입니다.
// 즉, "서버랑 통신하는 로직"을 화면(UI) 코드에서 분리해서
// 한 군데 모아두는 계층이에요. (Repository 패턴이랑 비슷)
//
// 화면(위젯)은 이 클래스의 메서드만 호출하면 되고,
// "어떤 URL로, 어떤 메서드로 요청하는지"는 몰라도 됩니다.
// (관심사 분리 = Separation of Concerns, 백엔드에서도 똑같이 하시죠)
// ============================================================
class ApiService{

  // Dio는 Flutter/Dart에서 가장 많이 쓰는 HTTP 클라이언트 라이브러리입니다.
  // Java의 RestTemplate / WebClient, 혹은 Node의 axios랑 같은 역할이라고
  // 생각하시면 됩니다.
  final Dio _dio = Dio(BaseOptions(
    // baseUrl: 모든 요청 앞에 자동으로 붙는 공통 주소.
    // 즉 _dio.get('/api/body-info') 를 호출하면
    // 실제로는 http://localhost:8080/api/body-info 로 요청이 나갑니다.
    // 💡 에뮬레이터면 10.0.2.2, 실기기(폰) 테스트나 웹이면 실제 백엔드 IP 주소를 적어주세요.
    baseUrl: 'http://localhost:8080', 
    connectTimeout: const Duration(seconds: 5), // 연결 시도 제한시간
    receiveTimeout: const Duration(seconds: 5), // 응답 수신 제한시간
  ));

  // ------------------------------------------------------------
  // GET /api/body-info/recent?memberId=xxx
  // ------------------------------------------------------------
  // 최근 체성분 기록 리스트 가져오기 리퀘스트
  //
  // Future<List<BodyInfoModel>> : 이 함수는 "비동기로" 실행되고,
  // 결과값으로 List<BodyInfoModel>을 (나중에) 돌려준다는 뜻입니다.
  // 백엔드의 Java CompletableFuture<List<BodyInfoDto>> 랑 개념이 같습니다.
  // 네트워크 요청은 시간이 걸리니까 "끝날 때까지 기다렸다가" 결과를
  // 돌려주는 방식이고, 호출하는 쪽에서는 await 키워드로 기다립니다.
  Future<List<BodyInfoModel>> getRescentBodyInfos(int memberId) async {
    try {
      // 주소창 뒤에 Query Parameter (?memberId=1) 형태로 전달 
      final response = await _dio.get(
        '/api/body-info/recent',
        queryParameters: {'memberId': memberId},
      );
      
      if (response.statusCode == 200) {
        // response.data는 서버가 준 JSON을 Dio가 이미 List/Map 형태로
        // 자동 파싱해준 것입니다. (Jackson이 자동으로 역직렬화해주는 것과 비슷)
        List<dynamic> data = response.data;

        // JSON 리스트(각 원소는 Map<String, dynamic>)를
        // 우리가 다루기 편한 Dart 객체(BodyInfoModel)로 하나씩 변환합니다.
        // .map()은 자바 스트림의 .map()이랑 완전히 동일한 개념이에요.
        // fromJson()은 BodyInfoModel 클래스 안에 정의된 "JSON → 객체" 변환 생성자입니다.
        return data.map((json) => BodyInfoModel.fromJson(json)).toList();
      } else {
        throw Exception('서버 응답 에러: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 에러, 파싱 에러 등을 여기서 한 번에 잡아서
      // 사람이 이해하기 쉬운 메시지로 다시 던져줍니다.
      throw Exception('데이터를 불러오는데 실패했습니다: $e');
    }
  }

  // ------------------------------------------------------------
  // GET /api/body-info/dashboard?memberId=xxx
  // ------------------------------------------------------------
  //Dashboard 데이터 가져오기 request
  Future<DashboardResponse> getDashboard(int memberId) async {
    final response = await _dio.get(
      '/api/body-info/dashboard',
      queryParameters: {'memberId': memberId},);
    return DashboardResponse.fromJson(response.data);
  }

  // ------------------------------------------------------------
  // POST /api/body-info?memberId=xxx
  // ------------------------------------------------------------
  // 체성분 기록 저장 request
  //
  // 파라미터 앞에 `required`가 붙은 건 "이 값 없으면 컴파일 에러"라는
  // 뜻입니다 (Java의 @NotNull 같은 컴파일타임 강제라고 보시면 됩니다).
  // `{ }`로 감싼 파라미터들은 "이름을 붙여서 호출"하는 named parameter
  // 문법입니다. 예: postBodyInfo(memberId: 1, weight: 68.4, ...)
  // 순서 안 지켜도 되고, 호출하는 쪽 코드만 봐도 각 값이 뭔지 바로
  // 보여서 가독성이 좋아집니다. (Java엔 없는 Dart/Kotlin 스타일 문법)
  //
  // double? 처럼 타입 뒤에 ?가 붙은 건 "null이 허용된다"는 뜻입니다.
  // 반대로 double(물음표 없음)은 절대 null이 될 수 없습니다.
  // Java의 @Nullable / Optional<Double>과 비슷한 역할을,
  // Dart는 타입 시스템 차원에서 강제합니다 (null safety).
  Future<void> postBodyInfo({
    required int memberId,
    required String measureDate, // yyyy-MM-dd 형식 문자열. 서버 LocalDate와 매칭됨
    required double weight,
    double? height,
    double? muscleMass,
    double? fatMass,
    String? memo,
  }) async {
    try {
      final response = await _dio.post(
        '/api/body-info',
        // data: POST/PUT 요청의 "본문(body)"에 실릴 내용.
        // Dio가 이 Map을 자동으로 JSON 문자열로 직렬화해서 보내줍니다.
        // (Jackson이 @RequestBody DTO를 JSON으로 바꿔주는 것의 반대 과정)
        //
        // 여기 key 이름(memberId, measureDate, weight, ...)은 백엔드
        // @RequestBody DTO의 필드명과 정확히 일치해야 Jackson이 매핑할 수 있습니다.
        // memberId도 리소스를 생성하는 데 필요한 데이터이므로 쿼리 파라미터가
        // 아니라 body 안에 함께 담아 보냅니다. (POST/PUT처럼 리소스를
        // 생성/수정하는 요청은 body에, GET처럼 단순 조회 필터링은
        // 쿼리 파라미터에 담는 게 일반적인 REST 관례입니다)
        data: {
          'memberId': memberId,
          'measureDate': measureDate,
          'weight': weight,
          'height': height,
          'muscleMass': muscleMass,
          'fatMass': fatMass,
          'memo': memo,
        },
      );

      // 백엔드에서 @PostMapping 성공 시 보통 200(OK) 또는 201(Created)을
      // 반환하니 둘 다 성공으로 취급합니다.
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('서버 응답 에러: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('체성분 기록 저장에 실패했습니다: $e');
    }
  }
}