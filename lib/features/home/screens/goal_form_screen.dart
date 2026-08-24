import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/home/models/home_response.dart';
import 'package:fitmate_flutter/features/home/services/home_api_service.dart';
import 'package:fitmate_flutter/features/body_composition/models/dashboard_response.dart';

// ============================================================
// 목표 설정 화면 (첨부 HTML 목업의 isGoal 상태를 그대로 구현)
// - 지표(체중/근육량/체지방량/체지방률)를 중복 선택 가능
// - 선택한 지표마다 목표 수치(필수) + 목표 기한(선택)을 입력
// - 이미 설정된 목표가 있으면 해당 지표가 미리 체크되어 값이 채워짐
//
// 저장은 POST /api/goal로 "현재 체크된 지표 전체"를 보내는 방식이다.
// 서버가 보낸 목록으로 목표 전체를 교체하기 때문에, 체크를 해제한 지표는
// 요청에서 자연히 빠지면서 삭제되고, 전부 해제한 채로 저장하면
// {"goals": []}가 전송되어 목표가 모두 삭제된다.
// ============================================================

class GoalFormScreen extends StatefulWidget {
  final List<HomeGoal> existingGoals;
  final DashboardResponse dashboard;

  const GoalFormScreen({required this.existingGoals, required this.dashboard, super.key});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

/// 지표 1개에 대한 편집 중 상태 (선택 여부 + 목표 수치 + 목표 기한)
class _MetricDraft {
  final GoalMetric metric;
  final double? current;
  final TextEditingController targetController;
  bool selected;
  DateTime? targetDate;

  _MetricDraft({
    required this.metric,
    required this.current,
    required this.targetController,
    required this.selected,
    this.targetDate,
  });
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final HomeApiService _homeApiService = HomeApiService();
  late final Map<GoalMetric, _MetricDraft> _drafts;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _drafts = {for (final metric in GoalMetric.values) metric: _buildDraft(metric)};
  }

  @override
  void dispose() {
    for (final draft in _drafts.values) {
      draft.targetController.dispose();
    }
    super.dispose();
  }

  HomeGoal? _existingGoalFor(GoalMetric metric) {
    for (final goal in widget.existingGoals) {
      if (goal.metric == metric) return goal;
    }
    return null;
  }

  double? _currentValueFor(GoalMetric metric) {
    switch (metric) {
      case GoalMetric.weight:
        return widget.dashboard.latestWeight;
      case GoalMetric.muscleMass:
        return widget.dashboard.latestMuscleMass;
      case GoalMetric.bodyFatMass:
        return widget.dashboard.latestFatMass;
      case GoalMetric.bodyFatPercent:
        return widget.dashboard.fatPercentage;
    }
  }

  String _trimmedNumber(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
  }

  String get _unitForBodyFatPercent => '%';

  String _unitFor(GoalMetric metric) {
    return metric == GoalMetric.bodyFatPercent ? _unitForBodyFatPercent : 'kg';
  }

  _MetricDraft _buildDraft(GoalMetric metric) {
    final existing = _existingGoalFor(metric);
    return _MetricDraft(
      metric: metric,
      current: _currentValueFor(metric),
      selected: existing != null,
      targetController: TextEditingController(text: existing != null ? _trimmedNumber(existing.targetValue) : ''),
      targetDate: existing?.targetDate != null ? DateTime.tryParse(existing!.targetDate!) : null,
    );
  }

  String? _targetError(_MetricDraft draft) {
    if (!draft.selected) return null;
    final value = double.tryParse(draft.targetController.text.trim());
    if (value == null || value <= 0) return '0보다 큰 값을 입력해주세요';
    if (draft.metric == GoalMetric.bodyFatPercent && value > 100) return '체지방률은 100 이하로 입력해주세요';
    return null;
  }

  String? _dateError(_MetricDraft draft) {
    if (!draft.selected || draft.targetDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!draft.targetDate!.isAfter(today)) return '오늘 이후 날짜를 선택해주세요';
    return null;
  }

  bool get _anyInvalid =>
      _drafts.values.any((d) => d.selected && (_targetError(d) != null || _dateError(d) != null));

  // 전부 체크 해제한 채로 저장하는 것도 유효한 동작(목표 전체 삭제)이라
  // 선택 개수가 아니라 유효성 검증 통과 여부로만 저장 가능 여부를 판단한다.
  bool get _saveDisabled => _anyInvalid || _isSaving;

  Future<void> _pickDate(_MetricDraft draft) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.targetDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: FitMateTheme.colorPrimary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => draft.targetDate = picked);
    }
  }

  String _isoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_saveDisabled) return;

    // 현재 체크된 지표만 모아 보낸다 -> 서버가 이 목록으로 목표 전체를 교체하므로
    // 체크 해제한 지표는 자연히 빠지면서 삭제되고, 전부 해제하면 빈 배열이 전송된다.
    final goals = _drafts.values
        .where((d) => d.selected)
        .map((d) => GoalRequestItem(
              metric: d.metric,
              targetValue: double.parse(d.targetController.text.trim()),
              targetDate: d.targetDate != null ? _isoDate(d.targetDate!) : null,
            ))
        .toList();

    setState(() => _isSaving = true);
    try {
      await _homeApiService.saveGoals(goals);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('목표 설정', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '지표를 여러 개 선택해 각각 목표를 설정할 수 있어요. 홈에서 선택한 목표 전부의 진행률을 확인할 수 있어요',
                      style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    const Text('지표 선택 (중복 가능)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...GoalMetric.values.map(
                      (metric) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MetricCard(
                          draft: _drafts[metric]!,
                          unit: _unitFor(metric),
                          targetError: _targetError(_drafts[metric]!),
                          dateError: _dateError(_drafts[metric]!),
                          onToggle: (checked) => setState(() => _drafts[metric]!.selected = checked),
                          onTargetChanged: () => setState(() {}),
                          onPickDate: () => _pickDate(_drafts[metric]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // 유효성 문제가 있을 때만 회색으로 표시 (저장 중일 땐 계속 파란 배경 유지)
                    backgroundColor: _anyInvalid ? Theme.of(context).cardColor : FitMateTheme.colorPrimary,
                    disabledBackgroundColor: _anyInvalid ? Theme.of(context).cardColor : FitMateTheme.colorPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
                  ),
                  onPressed: _saveDisabled ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _anyInvalid ? Colors.grey : Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 지표 1개 카드 (체크박스 행 + 선택 시 목표 수치/기한 입력 확장)
// ============================================================

class _MetricCard extends StatelessWidget {
  final _MetricDraft draft;
  final String unit;
  final String? targetError;
  final String? dateError;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTargetChanged;
  final VoidCallback onPickDate;

  const _MetricCard({
    required this.draft,
    required this.unit,
    required this.targetError,
    required this.dateError,
    required this.onToggle,
    required this.onTargetChanged,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selected = draft.selected;

    return Container(
      decoration: BoxDecoration(
        color: selected ? FitMateTheme.colorPrimary.withOpacity(0.05) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
        border: Border.all(color: selected ? FitMateTheme.colorPrimary : Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
            onTap: () => onToggle(!selected),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Checkbox(
                    value: selected,
                    activeColor: FitMateTheme.colorPrimary,
                    onChanged: (v) => onToggle(v ?? false),
                  ),
                  Expanded(
                    child: Text(draft.metric.label,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  ),
                  Text(
                    draft.current != null ? '현재 ${_display(draft.current!)}$unit' : '기록 없음',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (selected)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('목표 수치 ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('*', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FitMateTheme.colorDanger)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildTargetField(context),
                  if (targetError != null) ...[
                    const SizedBox(height: 4),
                    Text(targetError!, style: const TextStyle(fontSize: 11, color: FitMateTheme.colorDanger)),
                  ],
                  const SizedBox(height: 14),
                  const Text('목표 기한 (선택)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 6),
                  _buildDateField(context),
                  if (dateError != null) ...[
                    const SizedBox(height: 4),
                    Text(dateError!, style: const TextStyle(fontSize: 11, color: FitMateTheme.colorDanger)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _display(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  Widget _buildTargetField(BuildContext context) {
    final hasError = targetError != null;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
        border: Border.all(color: hasError ? FitMateTheme.colorDanger : Colors.grey.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: draft.targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => onTargetChanged(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintText: '목표 수치 입력',
              ),
            ),
          ),
          Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final hasError = dateError != null;
    final label = draft.targetDate != null
        ? '${draft.targetDate!.year}-${draft.targetDate!.month.toString().padLeft(2, '0')}-${draft.targetDate!.day.toString().padLeft(2, '0')}'
        : '연도-월-일';

    return InkWell(
      borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
      onTap: onPickDate,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
          border: Border.all(color: hasError ? FitMateTheme.colorDanger : Colors.grey.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: draft.targetDate != null ? Theme.of(context).colorScheme.onSurface : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
