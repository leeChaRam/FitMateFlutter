/// 목표(goal)가 어떤 체성분 지표를 대상으로 하는지 (백엔드 문자열 enum)
enum GoalMetric {
  weight,
  muscleMass,
  bodyFatMass,
  bodyFatPercent;

  static GoalMetric fromApi(String? value) {
    switch (value) {
      case 'MUSCLE_MASS':
        return GoalMetric.muscleMass;
      case 'BODY_FAT_MASS':
        return GoalMetric.bodyFatMass;
      case 'BODY_FAT_PERCENT':
        return GoalMetric.bodyFatPercent;
      case 'WEIGHT':
      default:
        return GoalMetric.weight;
    }
  }

  String toApi() {
    switch (this) {
      case GoalMetric.weight:
        return 'WEIGHT';
      case GoalMetric.muscleMass:
        return 'MUSCLE_MASS';
      case GoalMetric.bodyFatMass:
        return 'BODY_FAT_MASS';
      case GoalMetric.bodyFatPercent:
        return 'BODY_FAT_PERCENT';
    }
  }

  // 화면에 보여줄 한글 라벨
  String get label {
    switch (this) {
      case GoalMetric.weight:
        return '체중';
      case GoalMetric.muscleMass:
        return '근육량';
      case GoalMetric.bodyFatMass:
        return '체지방량';
      case GoalMetric.bodyFatPercent:
        return '체지방률';
    }
  }

  // 근육량은 늘리는 게 목표, 나머지(체중/체지방)는 줄이는 게 목표
  bool get isDecreaseGoal => this != GoalMetric.muscleMass;
}

/// 사용자가 설정한 목표 1건 (현재값은 home api에 없어서 body-composition 최근 기록과 조합해서 사용)
class HomeGoal {
  final int id;
  final GoalMetric metric;
  final String unit;
  final double targetValue;
  final String? targetDate;

  const HomeGoal({
    required this.id,
    required this.metric,
    required this.unit,
    required this.targetValue,
    this.targetDate,
  });

  factory HomeGoal.fromJson(Map<String, dynamic> json) {
    return HomeGoal(
      id: json['id'] as int,
      metric: GoalMetric.fromApi(json['metric'] as String?),
      unit: json['unit'] as String? ?? '',
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 0,
      targetDate: json['targetDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metric': metric.toApi(),
      'unit': unit,
      'targetValue': targetValue,
      'targetDate': targetDate,
    };
  }
}

/// POST /api/goal 요청 바디의 goals 배열 항목 1건
/// 목표 저장은 "현재 선택된 목표 전체로 교체"하는 방식이라 id는 필요 없다.
/// (보낸 목록에 없는 지표의 기존 목표는 서버에서 삭제됨. 빈 배열을 보내면 전체 삭제)
class GoalRequestItem {
  final GoalMetric metric;
  final double targetValue;
  final String? targetDate;

  const GoalRequestItem({required this.metric, required this.targetValue, this.targetDate});

  Map<String, dynamic> toJson() {
    return {
      'metric': metric.toApi(),
      'targetValue': targetValue,
      'targetDate': targetDate,
    };
  }
}

/// GET /api/home 응답
class HomeResponse {
  final String name;
  final List<HomeGoal> goals;
  final String? lastRecordDate;
  final int? daysSinceLastRecord;

  const HomeResponse({
    required this.name,
    this.goals = const [],
    this.lastRecordDate,
    this.daysSinceLastRecord,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      name: json['name'] as String? ?? '',
      goals: (json['goals'] as List<dynamic>? ?? [])
          .map((e) => HomeGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastRecordDate: json['lastRecordDate'] as String?,
      daysSinceLastRecord: json['daysSinceLastRecord'] as int?,
    );
  }
}
