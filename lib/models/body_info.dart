class BodyInfoModel{
  final int id;
  final String measureDate;
  final double weight;
  final double? muscleMass; // 비어 있을 수 있으므로 nullable
  final double? fatMass;
  final String? memo;
  final String createdAt;
  final int weightPrivacy; // null일 경우 기본값 1(PRIVATE) 세팅
  final int musclePrivacy;
  final int fatPrivacy;

  BodyInfoModel({
    required this.id,
    required this.measureDate,
    required this.weight,
    this.muscleMass,
    this.fatMass,
    this.memo,
    required this.createdAt,
    required this.weightPrivacy,
    required this.musclePrivacy,
    required this.fatPrivacy
  });

  // 백엔드 JSON 데이터를 Dart 객체로 변환 (Null 방어막 작동)
  factory BodyInfoModel.fromJson(Map<String, dynamic> json) {
    return BodyInfoModel(
      id: json['id'] as int, 
      measureDate: json['measureDate'] as String , 
      // 백엔드에서 Double이 정수(예: 68)로 오면 Dart에서 에러가 나므로 toDouble()로 처리
      weight: (json['weight'] as num).toDouble(),
      muscleMass: json['muscleMass'] != null ? (json['muscleMass'] as num).toDouble() : null,
      fatMass: json['fatMass'] != null ? (json['fatMass'] as num).toDouble() : null,
      memo: json['memo'] as String?,
      createdAt: json['createdAt'] as String,
      // 💡 만약 null 값이 내려오면 대입 연산자(??)를 통해 기본값 1(나만보기)로 채워 앱 터짐을 방지합니다.
      weightPrivacy: json['weightPrivacy'] ?? 1,
      musclePrivacy: json['musclePrivacy'] ?? 1,
      fatPrivacy: json['fatPrivacy'] ?? 1,
      );

  }
}