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

// BMI 범위 카테고리 (증감이 아니라 현재 어느 범위에 속하는지 의미)
// 백엔드 0: 저체중, 1: 정상, 2: 과체중, 3: 비만

enum BmiCategory {
  underweight,
  normal,
  overweight,
  obese;

  static BmiCategory fromInt(int? value) {
    switch (value) {
      case 0:
        return BmiCategory.underweight;
      case 2:
        return BmiCategory.overweight;
      case 3:
        return BmiCategory.obese;
      case 1:
      default:
        return BmiCategory.normal;      
    }
  }

  int toInt() {
    switch (this) {
      case BmiCategory.underweight:
        return 0;
      case BmiCategory.normal:
        return 1;
      case BmiCategory.overweight:
        return 2;
      case BmiCategory.obese:
        return 3;
    }
  }

  // 화면에 보여줄 한글 라벨 
  String get label {
    switch (this) {
      case BmiCategory.underweight:
        return '저체중';
      case BmiCategory.normal:
        return '정상 범위';
      case BmiCategory.overweight:
        return '과체중';
      case BmiCategory.obese:
        return '비만';
    }
  }

  Color get color {
    switch (this) {
      case BmiCategory.underweight:
        return FitMateTheme.colorWarning;
      case BmiCategory.normal:
        return FitMateTheme.colorPositive;
      case BmiCategory.overweight:
        return FitMateTheme.colorWarning;
      case BmiCategory.obese:
        return FitMateTheme.colorDanger;
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

  final double? fatPercentage;
  final String? fatPercentageDelta;
  final ChangeStatus fatPercentageStatus;

  // 백엔드에서 계산된 지표
  final double? bmi;
  final BmiCategory bmiStatus;

  final int? bmr; // 기초대사량
  final String? bmrDelta;
  final ChangeStatus bmrStatus;


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
    this.fatPercentage,
    this.fatPercentageDelta,
    this.fatPercentageStatus = ChangeStatus.same,
    this.bmi,
    this.bmiStatus = BmiCategory.normal,
    this.bmr,
    this.bmrDelta,
    this.bmrStatus = ChangeStatus.same,
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
      fatPercentage: (json['fatPercentage'] as num?)?.toDouble(),
      fatPercentageDelta: json['fatPercentageDelta'] as String?,
      fatPercentageStatus: ChangeStatus.fromInt(json['fatPercentageStatus'] as int?),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmiStatus: BmiCategory.fromInt(json['bmiStatus'] as int?),
      bmr: json['bmr'] as int?,
      bmrDelta: json['bmrDelta'] as String?,
      bmrStatus: ChangeStatus.fromInt(json['bmrStatus'] as int?),
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
      'fatPercentage': fatPercentage,
      'fatPercentageDelta': fatPercentageDelta,
      'fatPercentageStatus': fatPercentageStatus.toInt(),
      'bmi': bmi,
      'bmiStatus': bmiStatus.toInt(),
      'bmr': bmr,
      'bmrDelta': bmrDelta,
      'bmrStatus': bmrStatus.toInt(),
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
