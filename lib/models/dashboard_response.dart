import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';

/// 측정치 증감 상태 (백엔드 0: 다운, 1: 변동없음, 2: 업)
enum ChangeStatus {
  down,
  same,
  up;

  static ChangeStatus fromInt(int? value) {
    switch (value) {
      case 0:
        return ChangeStatus.down;
      case 2:
        return ChangeStatus.up;
      case 1:
      default:
        return ChangeStatus.same;
    }
  }

  int toInt() {
    switch (this) {
      case ChangeStatus.down:
        return 0;
      case ChangeStatus.same:
        return 1;
      case ChangeStatus.up:
        return 2;
    }
  }
}
extension ChangeStatusColor on ChangeStatus {
  Color get color {
    switch (this){
      case ChangeStatus.down:
        return FitMateTheme.colorDanger;
      case ChangeStatus.same:
        return Colors.grey;
      case ChangeStatus.up:
        return FitMateTheme.colorPositive;
    }
  }

}

/// 대시보드 상단 요약 + 하단 히스토리를 함께 담는 응답 모델
class DashboardResponse {
  // 최근 측정 요약
  final double? latestWeight;
  final double? latestMuscleMass;
  final double? latestFatMass;
  final String? measureDate;

  // 변동폭 (이전 측정 대비)
  final String? weightDelta;
  final ChangeStatus weightStatus;

  final String? muscleDelta;
  final ChangeStatus muscleStatus;

  final String? fatDelta;
  final ChangeStatus fatStatus;

  // 백엔드에서 계산된 지표
  final double? bmi;
  final int? bmr;

  // 차트/리스트용 전체 히스토리
  final List<BodyInfoHistory> historyList;

  const DashboardResponse({
    this.latestWeight,
    this.latestMuscleMass,
    this.latestFatMass,
    this.measureDate,
    this.weightDelta,
    this.weightStatus = ChangeStatus.same,
    this.muscleDelta,
    this.muscleStatus = ChangeStatus.same,
    this.fatDelta,
    this.fatStatus = ChangeStatus.same,
    this.bmi,
    this.bmr,
    this.historyList = const [],
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      latestWeight: (json['latestWeight'] as num?)?.toDouble(),
      latestMuscleMass: (json['latestMuscleMass'] as num?)?.toDouble(),
      latestFatMass: (json['latestFatMass'] as num?)?.toDouble(),
      measureDate: json['measureDate'] as String?,
      weightDelta: json['weightDelta'] as String?,
      weightStatus: ChangeStatus.fromInt(json['weightStatus'] as int?),
      muscleDelta: json['muscleDelta'] as String?,
      muscleStatus: ChangeStatus.fromInt(json['muscleStatus'] as int?),
      fatDelta: json['fatDelta'] as String?,
      fatStatus: ChangeStatus.fromInt(json['fatStatus'] as int?),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmr: json['bmr'] as int?,
      historyList: (json['historyList'] as List<dynamic>? ?? [])
          .map((e) => BodyInfoHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestWeight': latestWeight,
      'latestMuscleMass': latestMuscleMass,
      'latestFatMass': latestFatMass,
      'measureDate': measureDate,
      'weightDelta': weightDelta,
      'weightStatus': weightStatus.toInt(),
      'muscleDelta': muscleDelta,
      'muscleStatus': muscleStatus.toInt(),
      'fatDelta': fatDelta,
      'fatStatus': fatStatus.toInt(),
      'bmi': bmi,
      'bmr': bmr,
      'historyList': historyList.map((e) => e.toJson()).toList(),
    };
  }
}

/// 과거 측정 기록 1건 (직전 대비 증감치 포함)
class BodyInfoHistory {
  final int? id;
  final String? measureDate;
  final double? weight;
  final double? muscleMass;
  final double? fatMass;

  final String? weightDelta;
  final ChangeStatus weightStatus;

  final String? muscleDelta;
  final ChangeStatus muscleStatus;

  final String? fatDelta;
  final ChangeStatus fatStatus;

  const BodyInfoHistory({
    this.id,
    this.measureDate,
    this.weight,
    this.muscleMass,
    this.fatMass,
    this.weightDelta,
    this.weightStatus = ChangeStatus.same,
    this.muscleDelta,
    this.muscleStatus = ChangeStatus.same,
    this.fatDelta,
    this.fatStatus = ChangeStatus.same,
  });

  factory BodyInfoHistory.fromJson(Map<String, dynamic> json) {
    return BodyInfoHistory(
      id: json['id'] as int?,
      measureDate: json['measureDate'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      muscleMass: (json['muscleMass'] as num?)?.toDouble(),
      fatMass: (json['fatMass'] as num?)?.toDouble(),
      weightDelta: json['weightDelta'] as String?,
      weightStatus: ChangeStatus.fromInt(json['weightStatus'] as int?),
      muscleDelta: json['muscleDelta'] as String?,
      muscleStatus: ChangeStatus.fromInt(json['muscleStatus'] as int?),
      fatDelta: json['fatDelta'] as String?,
      fatStatus: ChangeStatus.fromInt(json['fatStatus'] as int?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'measureDate': measureDate,
      'weight': weight,
      'muscleMass': muscleMass,
      'fatMass': fatMass,
      'weightDelta': weightDelta,
      'weightStatus': weightStatus.toInt(),
      'muscleDelta': muscleDelta,
      'muscleStatus': muscleStatus.toInt(),
      'fatDelta': fatDelta,
      'fatStatus': fatStatus.toInt(),
    };
  }
}
