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