import 'package:fitmate_flutter/features/body_composition/models/dashboard_response.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/body_composition/screens/input_screen.dart';
import 'package:fitmate_flutter/services/api_service.dart';

// ============================================================
// 대시보드 메인 화면
// 구조: TopSummaryCard → TrendChartCard → GoalProgressCard
//       → DetailMetricsGrid → HistoryListCard → 새 기록 추가 버튼
// 각 섹션은 독립 위젯이며, 섹션 타이틀도 각 위젯이 자체 포함한다.
// ============================================================

class BodyCompositionsDashboard extends StatefulWidget {
  const BodyCompositionsDashboard({super.key});

  @override
  State<BodyCompositionsDashboard> createState() => _BodyCompositionsDashboardState();
}
  

class _BodyCompositionsDashboardState extends State<BodyCompositionsDashboard> {
  final ApiService apiService = ApiService();
  late Future<DashboardResponse> _futureDashboard;

  @override
  void initState() {
    super.initState();
    // 여기서 딱 한 번만 API 호출
    _futureDashboard = apiService.getDashboard(30001); // TODO: 실제 로그인 유저 id로 교체
  }

  void _refreshDashboard() {
    setState(() {
      _futureDashboard = apiService.getDashboard(30001); // TODO: 실제 로그인 유저 id로 교체
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('내 체성분', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: cs.onSurface)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions : [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.menu, color: FitMateTheme.colorPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // 1. 대시보드 통합 API 한번만 수행 
      body: FutureBuilder<DashboardResponse>(
        future: _futureDashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('데이터를 불러오지 못했습니다: ${snapshot.error}'));
          }
          final dashboard = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 최신 측정 요약 그라데이션 카드
                TopSummaryCard(data: dashboard),

                // 변화 추이 차트 카드
                TrendChartCard(historyList: dashboard.historyList),

                const SizedBox(height: 12),

                // 목표 진행률 카드
                const GoalProgressCard(),

                // 세부 지표 (타이틀 + 그리드)
                DetailMetricsGrid(data: dashboard),

                // 측정 기록 (헤더 + 리스트)
                HistoryListCard(
                  historyList: dashboard.historyList,
                  onViewAll: () {
                    // TODO: 전체 기록 화면으로 이동
                  },
                ),

                const SizedBox(height: 20),

                // 새 기록 추가 버튼(CTA)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FitMateTheme.colorPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const BodyCompositionInputScreen()),
                        );
                        
                        // 입력 화면에서 저장 성공(true)하고 돌아온 경우에만 새로고침
                        // 사용자가 그냥 '취소'를 눌러서 돌아온 경우(result가 null)엔
                        // 불필요한 API 재호출을 안하도록 막음
                        if (result == true) {
                          _refreshDashboard();
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('새 기록 추가', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      )
    );
  }
}
// ============================================================
// 최신 측정 요약 그라데이션 카드
// ============================================================

class TopSummaryCard extends StatelessWidget {
  final DashboardResponse data;
  const TopSummaryCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [FitMateTheme.colorPrimary, Color(0xff6541F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(FitMateTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('최근 측정 · ${data.measureDate ?? "-"}',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${data.latestWeight ?? "-"}',
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
                const Text(' kg', style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(width: 8),
                if (data.weightDelta != null && data.weightDelta != '-')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0x4000BF40), borderRadius: BorderRadius.circular(99)),
                    child: Text('${data.weightDelta} kg',
                        style: TextStyle(
                            fontSize: 13,
                            color: data.weightStatus.colorFor(higherIsBetter: false),
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('근육량', '${data.latestMuscleMass ?? "-"}', 'kg'),
                _buildSummaryItem('체지방률', '${data.fatPercentage ?? "-"}', '%'),
                _buildSummaryItem('BMI', '${data.bmi ?? "-"}', ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 1),
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            children: [
              TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 변화 추이 차트 카드 (기간 탭 + fl_chart 라인 차트)
// ============================================================

// 차트 기간 필터
enum ChartPeriod {
  oneMonth('1개월', 30),
  threeMonths('3개월', 90),
  all('전체', null);

  final String label;
  final int? days;

  const ChartPeriod(this.label, this.days);
}

class TrendChartCard extends StatefulWidget {
  final List<BodyInfoHistory> historyList;
  const TrendChartCard({required this.historyList, super.key});

  @override
  State<TrendChartCard> createState() => _TrendChartCardState();
}

class _TrendChartCardState extends State<TrendChartCard> {
  ChartPeriod _selectedPeriod = ChartPeriod.threeMonths;

  /// 선택된 기간에 맞게 필터링 + 시간순(과거→최신) 정렬된 리스트 반환
  List<BodyInfoHistory> get _filteredList {
    // API가 최신순으로 주므로 차트용으로는 뒤집어서 과거→최신 순으로
    final chronological = widget.historyList.reversed.toList();

    final days = _selectedPeriod.days;
    if (days == null) return chronological; // 전체

    final cutoff = DateTime.now().subtract(Duration(days: days));
    return chronological.where((item) {
      final date = DateTime.tryParse(item.measureDate ?? '');
      return date != null && date.isAfter(cutoff);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final list = _filteredList;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 헤더: 타이틀 + 기간 탭
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('변화 추이', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
                    ),
                    child: Row(
                      children: ChartPeriod.values.map((period) {
                        return _buildTabButton(period);
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 차트 영역
              SizedBox(
                height: 140,
                width: double.infinity,
                child: list.length < 2
                    ? const Center(
                        child: Text('그래프를 그리려면 기록이 2개 이상 필요해요', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      )
                    : _buildChart(list),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(ChartPeriod period) {
    final isActive = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period; // 💡 탭 클릭 → 상태 변경 → 차트 다시 그림
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
        ),
        child: Text(
          period.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.black : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildChart(List<BodyInfoHistory> list) {
    // 체중 데이터 → (x: 인덱스, y: 체중) 좌표로 변환
    final spots = <FlSpot>[];
    for (int i = 0; i < list.length; i++) {
      final weight = list[i].weight;
      if (weight != null) {
        spots.add(FlSpot(i.toDouble(), weight));
      }
    }

    // y축 범위를 데이터 최소/최대에 여유(padding) 줘서 계산
    final weights = spots.map((s) => s.y);
    final minY = weights.reduce((a, b) => a < b ? a : b) - 1;
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 3).clamp(0.5, double.infinity),
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.12),
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false), // 축 라벨 숨김 (기존 디자인 유지)
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final item = list[spot.x.toInt()];
                return LineTooltipItem(
                  '${item.measureDate}\n${spot.y} kg',
                  const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: FitMateTheme.colorPrimary,
            barWidth: 2,
            isCurved: true,           // 부드러운 곡선
            curveSmoothness: 0.3,
            dotData: FlDotData(
              show: true,
              // 마지막 점(최신 기록)만 크게 표시
              checkToShowDot: (spot, barData) => spot.x == spots.last.x,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 5,
                color: FitMateTheme.colorPrimary,
                strokeWidth: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ============================================================
// 목표 진행률 카드
// TODO: 목표 설정 기능이 생기면 데이터를 파라미터로 받도록 변경
// ============================================================

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('목표 진행률', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const SizedBox(height: 12),
              _buildProgressBar('체지방률', '21.3%', '목표 18%', 0.72, '3.3% 남았어요 · 약 2~3개월 예상',
                  [FitMateTheme.colorWarning, FitMateTheme.colorDanger]),
              const SizedBox(height: 8),
              _buildProgressBar('근육량', '34.1 kg', '목표 36 kg', 0.88, '1.9 kg 남았어요 · 잘 하고 있어요! 💪',
                  [FitMateTheme.colorPrimary, FitMateTheme.colorPositive]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(String title, String current, String target, double progress, String sub, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(FitMateTheme.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              RichText(
                text: TextSpan(
                  text: '$current ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  children: [
                    TextSpan(text: '/ $target', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(colors.first),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ============================================================
// 세부 지표 (섹션 타이틀 + 2열 그리드)
// ============================================================

class DetailMetricsGrid extends StatelessWidget {
  final DashboardResponse data;
  const DetailMetricsGrid({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 타이틀
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('세부 지표', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
        ),

        // 지표 그리드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildMetricTile(context, '체중', '${data.latestWeight ?? "-"} kg', data.weightDelta ?? '',
                  data.weightStatus.colorFor(higherIsBetter: false)),
              _buildMetricTile(context, '근육량', '${data.latestMuscleMass ?? "-"} kg', data.muscleDelta ?? '',
                  data.muscleStatus.colorFor(higherIsBetter: true)),
              _buildMetricTile(context, '체지방량', '${data.latestFatMass ?? "-"} kg', data.fatDelta ?? '',
                  data.fatStatus.colorFor(higherIsBetter: false)),
              _buildMetricTile(context, '체지방률', '${data.fatPercentage ?? "-"} %', data.fatPercentageDelta ?? '',
                  data.fatPercentageStatus.colorFor(higherIsBetter: false)),
              // BMI는 증감이 아니라 범위 카테고리 → 라벨/색상은 BmiCategory가 결정
              _buildMetricTile(context, 'BMI', '${data.bmi ?? "-"}', data.bmiStatus.label, data.bmiStatus.color),
              _buildMetricTile(context, '기초대사량', '${data.bmr ?? "-"} kcal', data.bmrDelta ?? '',
                  data.bmrStatus.colorFor(higherIsBetter: true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, String delta, Color deltaColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(FitMateTheme.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (delta.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: deltaColor.withOpacity(0.15), borderRadius: BorderRadius.circular(99)),
              child: Text(delta, style: TextStyle(fontSize: 12, color: deltaColor, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// 측정 기록 (섹션 헤더 + 리스트 카드)
// ============================================================

class HistoryListCard extends StatelessWidget {
  final List<BodyInfoHistory> historyList;
  final int maxItems; // 최대 표시 개수 (기본 3개)
  final VoidCallback? onViewAll; // '전체 보기' 클릭 콜백

  const HistoryListCard({
    required this.historyList,
    this.maxItems = 3,
    this.onViewAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더: 타이틀 + 전체 보기
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('측정 기록', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text('전체 보기',
                    style: TextStyle(fontSize: 14, color: FitMateTheme.colorPrimary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),

        // 기록 리스트 카드
        if (historyList.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
            ),
            child: const Center(
              child: Text('측정 기록이 없습니다.', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
            ),
            child: Column(
              children: List.generate(
                historyList.take(maxItems).length,
                (index) {
                  final visibleList = historyList.take(maxItems).toList();
                  final item = visibleList[index];
                  final isLast = index == visibleList.length - 1;
                  // 리스트가 최신순이므로 '첫 기록'은 전체 기록이 maxItems 이하일 때의 마지막 항목
                  final isFirstRecord = historyList.length <= maxItems && isLast;

                  return _HistoryRow(
                    item: item,
                    isFirst: isFirstRecord,
                    isLast: isLast,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final BodyInfoHistory item;
  final bool isFirst;
  final bool isLast;

  const _HistoryRow({
    required this.item,
    this.isFirst = false,
    this.isLast = false,
  });

  /// "2026-07-03" → (day: "03", month: "7월")
  (String, String) _parseDate(String? dateStr) {
    if (dateStr == null) return ('-', '');
    final date = DateTime.tryParse(dateStr);
    if (date == null) return ('-', '');
    return (date.day.toString().padLeft(2, '0'), '${date.month}월');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (day, month) = _parseDate(item.measureDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
      ),
      child: Row(
        children: [
          // 날짜 영역
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.1)),
                Text(month, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 핵심 지표 가로 배열
          Expanded(
            child: Row(
              children: [
                _buildHistoryChip(cs, '체중', '${item.weight ?? "-"}'),
                const SizedBox(width: 16),
                _buildHistoryChip(cs, '근육', '${item.muscleMass ?? "-"}'),
                const SizedBox(width: 16),
                _buildHistoryChip(cs, '체지방', '${item.fatMass ?? "-"}'),
              ],
            ),
          ),

          // 증감 상태 영역
          if (isFirst)
            const Text('첫 기록', style: TextStyle(fontSize: 11, color: Colors.grey))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if ((item.weightDelta ?? '').isNotEmpty && item.weightDelta != '-')
                  Text(
                    item.weightDelta!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: item.weightStatus.colorFor(higherIsBetter: false),
                    ),
                  ),
                if ((item.muscleDelta ?? '').isNotEmpty && item.muscleDelta != '-')
                  Text(
                    item.muscleDelta!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: item.muscleStatus.colorFor(higherIsBetter: true),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryChip(ColorScheme cs, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.onSurface)),
      ],
    );
  }
}
