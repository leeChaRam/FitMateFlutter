import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/home/models/home_response.dart';
import 'package:fitmate_flutter/features/home/services/home_api_service.dart';
import 'package:fitmate_flutter/features/body_composition/models/dashboard_response.dart';
import 'package:fitmate_flutter/features/body_composition/services/body_api_service.dart';
import 'package:fitmate_flutter/features/body_composition/screens/input_screen.dart';
import 'package:fitmate_flutter/features/home/screens/goal_form_screen.dart';

// ============================================================
// 홈 화면
// 구조: 인사말 헤더 → 기록 추가 CTA → 리마인더 배너(조건부)
//       → 내 목표(0~4개, 유동적) → 서클 피드(임시 더미 데이터)
// 각 섹션은 독립 위젯이며, 섹션 타이틀도 각 위젯이 자체 포함한다.
//
// 목표(goal)의 현재값은 /api/home 응답에 없어서, 체성분 대시보드 API
// (/api/body-info/dashboard)의 최근 측정값과 조합해서 진행률을 계산한다.
// 서클 피드는 아직 관련 API가 없어서 더미 데이터를 사용하며,
// home api에 서클 데이터가 추가되면 이 부분만 교체하면 된다.
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// 홈 화면 렌더링에 필요한 두 API 응답을 함께 들고 다니기 위한 묶음
class _HomeData {
  final HomeResponse home;
  final DashboardResponse dashboard;
  const _HomeData({required this.home, required this.dashboard});
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeApiService _homeApiService = HomeApiService();
  final BodyApiService _bodyApiService = BodyApiService();
  late Future<_HomeData> _futureHomeData;

  bool _reminderDismissed = false;

  @override
  void initState() {
    super.initState();
    _futureHomeData = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    // 홈 요약 + 최근 체성분 기록을 동시에 요청
    final results = await Future.wait([
      _homeApiService.getHome(),
      _bodyApiService.getDashboard(),
    ]);
    return _HomeData(
      home: results[0] as HomeResponse,
      dashboard: results[1] as DashboardResponse,
    );
  }

  void _refresh() {
    setState(() {
      _futureHomeData = _loadHomeData();
    });
  }

  Future<void> _goRecord() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const BodyCompositionInputScreen()),
    );
    // 입력 화면에서 저장 성공(true)하고 돌아온 경우에만 새로고침
    if (result == true) {
      _refresh();
    }
  }

  // 목표 카드/CTA를 누르면 전체 지표를 한번에 관리하는 목표 설정 화면으로 이동
  Future<void> _openGoalForm({
    required List<HomeGoal> existingGoals,
    required DashboardResponse dashboard,
  }) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GoalFormScreen(existingGoals: existingGoals, dashboard: dashboard),
      ),
    );
    // 목표 설정 화면에서 저장 성공(true)하고 돌아온 경우에만 새로고침
    if (saved == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_HomeData>(
          future: _futureHomeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text('데이터를 불러오지 못했습니다: ${snapshot.error}'));
            }

            final home = snapshot.data!.home;
            final dashboard = snapshot.data!.dashboard;

            // 최근 기록으로부터 사흘 이상 지났을 때만 리마인더 노출
            final showReminder = !_reminderDismissed &&
                (home.daysSinceLastRecord ?? 0) >= 3;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(name: home.name),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FitMateTheme.colorPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(FitMateTheme.radiusLg),
                              ),
                            ),
                            onPressed: _goRecord,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('기록 추가',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        if (showReminder) ...[
                          const SizedBox(height: 14),
                          _ReminderCallout(
                            daysSinceLastRecord: home.daysSinceLastRecord!,
                            onDismiss: () => setState(() => _reminderDismissed = true),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // ---- 내 목표 (0~4개, 유동적) ----
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('내 목표', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            if (home.goals.isNotEmpty)
                              TextButton(
                                onPressed: () => _openGoalForm(existingGoals: home.goals, dashboard: dashboard),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                child: const Text('+ 목표 추가',
                                    style: TextStyle(fontSize: 13, color: FitMateTheme.colorPrimary, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (home.goals.isEmpty)
                          _NoGoalCard(
                            onSetGoal: () => _openGoalForm(existingGoals: home.goals, dashboard: dashboard),
                          )
                        else
                          ...home.goals.map(
                            (goal) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _GoalCard(
                                goal: goal,
                                dashboard: dashboard,
                                onTap: () => _openGoalForm(existingGoals: home.goals, dashboard: dashboard),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // ---- 서클 피드 (임시 더미 데이터) ----
                        const Text('서클 피드', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ..._mockFeedItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _FeedCard(item: item),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// 인사말 헤더
// ============================================================

class _HomeHeader extends StatelessWidget {
  final String name;
  const _HomeHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$name님, 안녕하세요',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
          // TODO: 알림 기능이 생기면 실제 안 읽은 알림 여부로 배지 표시
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: cs.outline),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 리마인더 배너 (마지막 기록으로부터 일정 기간이 지났을 때)
// ============================================================

class _ReminderCallout extends StatelessWidget {
  final int daysSinceLastRecord;
  final VoidCallback onDismiss;

  const _ReminderCallout({required this.daysSinceLastRecord, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: FitMateTheme.colorWarning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
        border: Border.all(color: FitMateTheme.colorWarning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⏰ ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text('기록한 지 $daysSinceLastRecord일이 지났어요',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 4),
            child: Text('지금 기록을 남기고 진행 상황을 확인해보세요.',
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDismiss,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Text('닫기', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 목표가 없을 때 안내 카드
// ============================================================

class _NoGoalCard extends StatelessWidget {
  final VoidCallback onSetGoal;
  const _NoGoalCard({required this.onSetGoal});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('목표를 설정해보세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('목표를 등록하면 진행률을 확인할 수 있어요',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onSetGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: FitMateTheme.colorPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusSm)),
              ),
              child: const Text('설정하기', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 목표 카드 1건
// 현재값은 body-composition 대시보드의 최근 측정값에서 지표별로 가져와
// 목표값과 비교해 진행률(근사치)을 계산한다.
// 마우스를 올리면(hover) 은은한 그림자/테두리가 나타나고, 클릭하면
// 목표 설정 화면으로 이동한다.
// ============================================================

class _GoalCard extends StatefulWidget {
  final HomeGoal goal;
  final DashboardResponse dashboard;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.dashboard, required this.onTap});

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  // 마우스 오버 시 카드에 그림자/테두리를 보여주기 위한 상태
  bool _hovering = false;

  HomeGoal get goal => widget.goal;
  DashboardResponse get dashboard => widget.dashboard;

  double? get _currentValue {
    switch (goal.metric) {
      case GoalMetric.weight:
        return dashboard.latestWeight;
      case GoalMetric.muscleMass:
        return dashboard.latestMuscleMass;
      case GoalMetric.bodyFatMass:
        return dashboard.latestFatMass;
      case GoalMetric.bodyFatPercent:
        return dashboard.fatPercentage;
    }
  }

  // 시작 시점 기록이 없어 정확한 %는 아니고, "현재값이 목표값에
  // 얼마나 근접했는지"를 보여주는 근사치 진행률(0.0~1.0)
  double? get _progress {
    final current = _currentValue;
    if (current == null || current <= 0) return null;
    if (goal.metric.isDecreaseGoal) {
      if (current <= goal.targetValue) return 1.0;
      return (goal.targetValue / current).clamp(0.0, 1.0);
    } else {
      if (current >= goal.targetValue) return 1.0;
      if (goal.targetValue <= 0) return 0.0;
      return (current / goal.targetValue).clamp(0.0, 1.0);
    }
  }

  String get _remainingLabel {
    final current = _currentValue;
    if (current == null) return '최근 측정 기록이 없어요';
    final diff = (goal.targetValue - current).abs();
    if (diff < 0.05) return '목표를 달성했어요! 🎉';
    final verb = goal.metric.isDecreaseGoal ? '줄이면' : '늘리면';
    return '${diff.toStringAsFixed(1)}${goal.unit} 더 $verb 달성이에요';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = _progress;
    final current = _currentValue;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(FitMateTheme.radiusLg),
            border: Border.all(
              color: _hovering ? FitMateTheme.colorPrimary.withOpacity(0.4) : Colors.transparent,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: FitMateTheme.colorPrimary.withOpacity(0.18),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${goal.metric.label} 목표',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSecondary)),
                  if (progress != null)
                    Text('${(progress * 100).round()}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FitMateTheme.colorPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: current != null ? '$current${goal.unit} ' : '- ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
                  children: [
                    TextSpan(
                      text: '/ 목표 ${goal.targetValue}${goal.unit}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: progress ?? 0,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(FitMateTheme.colorPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(_remainingLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 서클 피드 (임시 더미 데이터)
// TODO: 서클 기능 API가 추가되면 아래 더미 데이터를 실제 응답으로 교체
// ============================================================

class _FeedItem {
  final String name;
  final String time;
  final String? badge;
  final int reactions;
  final int comments;

  const _FeedItem({
    required this.name,
    required this.time,
    this.badge,
    required this.reactions,
    required this.comments,
  });
}

const List<_FeedItem> _mockFeedItems = [
  _FeedItem(name: '지민', time: '10분 전', badge: '-0.8kg', reactions: 12, comments: 3),
  _FeedItem(name: '민수', time: '1시간 전', badge: '+1.2kg 근육량', reactions: 5, comments: 1),
  _FeedItem(name: '현지', time: '3시간 전', reactions: 8, comments: 2),
];

class _FeedCard extends StatelessWidget {
  final _FeedItem item;
  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: FitMateTheme.colorPrimary.withOpacity(0.12),
              child: Text(
                item.name.isNotEmpty ? item.name.substring(0, 1) : '?',
                style: const TextStyle(color: FitMateTheme.colorPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 14, color: cs.onSurface),
                            children: [
                              TextSpan(text: item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: '님이 새 기록을 남겼어요'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  if (item.badge != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: FitMateTheme.colorPositive.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item.badge!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FitMateTheme.colorPositive)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('💪 ${item.reactions}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 14),
                      Text('💬 ${item.comments}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
