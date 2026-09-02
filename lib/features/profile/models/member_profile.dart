enum PrivacyScope {
  // 체성분 지표를 서클 친구들에게 어디까지 보여줄지 (서버 정수값과 1:1 대응)
  // 0=나만보기, 1=변화량만 공개 2=그룹 전체 공개
  onlyMe(0, '나만 보기'),
  delta(1, '변화량만 공개'),
  group(2, '그룹 전체 공개');

  const PrivacyScope(this.value, this.label);

  // 서버로 보내고 받는 정수값
  final int value;
  // 화면에 표시할 한글 라벨
  final String label;

  // 서버가 내려준 정수를 enum으로 변환 모르는 값은 가장 보수적인 '나만 보기' 로
  static PrivacyScope fromValue(int? value){
    return PrivacyScope.values.firstWhere(
      (scope) => scope.value == value,
      orElse: () => PrivacyScope.onlyMe,
    );
  }
}

// 프로필 '공개 설정'의 세 행 - 어떤 지표를 편집 중인지 구분용 
enum PrivacyMetric {
  weight('체중'),
  muscle('근육량'),
  fat('체지방률');

  const PrivacyMetric(this.label);

  final String label;
}

class MemberProfile {
  final int id;
  final String email;
  final String name;
  final String? introduction;
  final String? profileImageUrl;
  final double height;
  final PrivacyScope weightPrivacy;
  final PrivacyScope musclePrivacy;
  final PrivacyScope fatPrivacy;

  const MemberProfile({
    required this.id,
    required this.email,
    required this.name,
    this.introduction,
    this.profileImageUrl,
    required this.height,
    required this.weightPrivacy,
    required this.musclePrivacy,
    required this.fatPrivacy,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      id: json['id'] as int, 
      email: json['email'] as String ? ?? '',
      name: json['name'] as String? ?? '', 
      introduction: json['introduction'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      weightPrivacy: PrivacyScope.fromValue(json['weightPrivacy'] as int?),
      musclePrivacy: PrivacyScope.fromValue(json['musclePrivacy'] as int?),
      fatPrivacy: PrivacyScope.fromValue(json['fatPrivacy'] as int?),
    );
  }
}