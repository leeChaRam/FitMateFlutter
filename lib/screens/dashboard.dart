import 'package:fitmate_flutter/models/dashboard_response.dart';
import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/screens/input_screen.dart';
import 'package:fitmate_flutter/services/api_service.dart';
import 'package:fitmate_flutter/models/body_info.dart';

class BodyCompositionsDashboard extends StatefulWidget {
  const BodyCompositionsDashboard({super.key});

  @override
  State<BodyCompositionsDashboard> createState() => _BodyCompositionsDashboardState();
}
  

class _BodyCompositionsDashboardState extends State<BodyCompositionsDashboard> {
  final ApiService apiService = ApiService();
  late final Future<DashboardResponse> _futureDashboard;

  @override
  void initState() {
    super.initState();
    // 여기서 딱 한 번만 API 호출
    _futureDashboard = apiService.getDashboard(1); // userId는 실제 값으로
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    print("============= 대시보드 빌드 시작 완료! ============="); //

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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('변화 추이', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(FitMateTheme.radiusSm)),
                                child: Row(
                                  children: [
                                    _buildTabButton('1개월', false),
                                    _buildTabButton('3개월', true),
                                    _buildTabButton('전체', false),
                                  ],        
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: CustomPaint(painter: ChartPainter(isDark: Theme.of(context).brightness == Brightness.dark)),

                          ),
                          const SizedBox(height: 12),
                          Container(height: 8,color: Theme.of(context).dividerColor),

                          // 목표 진행률 세션
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('목표 진행률', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                                const SizedBox(height: 12),
                                _buildProgressBar('체지방률', '21.3%', '목표 18%', 0.72, '3.3% 남았어요 · 약 2~3개월 예상', [FitMateTheme.colorWarning, FitMateTheme.colorDanger]),
                                const SizedBox(height: 8),
                                _buildProgressBar('근육량', '34.1 kg', '목표 36 kg', 0.88, '1.9 kg 남았어요 · 잘 하고 있어요! 💪', [FitMateTheme.colorPrimary, FitMateTheme.colorPositive]),
                              ],
                            ),
                          ),

                          Container(height: 8, color: Theme.of(context).dividerColor),

                          //세부 지표 타이틀 및 그리드
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text('세부 지표', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 1.6, // 타일의 가로세로 비율 조정
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              children:[
                                // 실제 백엔드에서 받아온 최신값(latestInfo)을 주입
                                _buildMetricTile(context, '체중', '${dashboard.latestWeight} kg', '▼ 0.8', FitMateTheme.colorDanger),
                                _buildMetricTile(context, '근육량', '${dashboard.latestMuscleMass?? "-"} kg', '▲ 0.3', FitMateTheme.colorPositive),
                                _buildMetricTile(context, '체지방량', '${dashboard.latestFatMass ?? "-"} kg', '▼ 1.1', FitMateTheme.colorDanger),
                                
                                // 💡 체지방률, BMI, 기초대사량은 현재 백엔드 엔티티에 없으므로, 수식이 완성되기 전까지 우선 기존 더미를 유지하거나 가공합니다.
                                _buildMetricTile(context, '체지방률', '21.3 %', '▼ 1.2', FitMateTheme.colorDanger),
                                _buildMetricTile(context, 'BMI', '22.8', '정상 범위', cs.outline, isNeu: true),
                                _buildMetricTile(context, '기초대사량', '1,648 kcal', '▲ 12', FitMateTheme.colorPositive),
                              ],
                            ),
                          ),
                          //측정 기록 헤더
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '측정 기록',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                ),
                                TextButton(
                                  onPressed: () {}, 
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                  child: const Text(
                                    '전체 보기',
                                    style: TextStyle(fontSize: 14, color: FitMateTheme.colorPrimary, fontWeight: FontWeight.w500)
                                  )
                                )
                              ],
                            ),
                          ),

                          //측정 기록 리스트 카드
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(FitMateTheme.radiusSm)
                            ),
                            child: Column(
                              children: [
                                _buildHistoryRow(Colors.black, Colors.grey, Colors.black54, '28', '5월', '68.4', '34.1', '21.3', '▼ 0.8', '▲ 0.3'),
                                _buildHistoryRow(Colors.black, Colors.grey, Colors.black54, '07', '5월', '69.2', '33.8', '22.5', '▼ 0.3', '▲ 0.1'),
                                _buildHistoryRow(Colors.black, Colors.grey, Colors.black54, '14', '4월', '69.5', '33.7', '22.8', '', '', isFirst: true, isLast: true),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 새 기록 추가 버튼(CTA)
                          Padding(
                            padding: const EdgeInsetsGeometry.all(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FitMateTheme.colorPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
                                ),
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyCompositionInputScreen()));
                                },
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('새 기록 추가', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ),

                        ],
                      ),
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

  Widget _buildTabButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.black : Colors.grey)),
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
              RichText(text: TextSpan(text: '$current ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black), children: [TextSpan(text: '/ $target', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey))])),
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


  Widget _buildHistoryRow(Color fg, Color labelColor, Color borderColor, String day, String month, String weight, String muscle, String fatPercent,
  String weightDelta, String muscleDelta, {bool isFirst = false, isLast = false}){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
          ? null
          : Border(bottom: BorderSide(color: borderColor, width: 0.5),),
      ),
      child: Row(
        children: [
          //날짜영역
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg, height: 1.1),),
                Text(month, style: TextStyle(fontSize: 11, color: labelColor)),
              ],
            ),
          ),

          const SizedBox(width: 8),

          //핵심 지표 가로 영역 배열
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildHistoryChip(labelColor, fg, '체중', weight),
                const SizedBox(width: 16),
                _buildHistoryChip(labelColor, fg, '근육', muscle),
                const SizedBox(width: 16),
                _buildHistoryChip(labelColor, fg, '체지방%', fatPercent),
              ],
            ),
          ),
          //증감 상태 영역
          if(isFirst)
            Text('첫 기록', style: TextStyle(fontSize: 11, color: labelColor))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (weightDelta.isNotEmpty)
                  Text(weightDelta, style: const TextStyle(fontSize: 12, fontWeight:FontWeight.w500, color: FitMateTheme.colorPositive)),
                if (muscleDelta.isNotEmpty)
                  Text(muscleDelta, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: FitMateTheme.colorDanger)),
              ],
            )
        ],
      ),
    );
  }

  // 기록 내부의 지표 칩 빌더
  Widget _buildHistoryChip(Color labelColor, Color fgColor, String label, String value){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: labelColor)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fgColor))
      ],
    );
  }
}

// 변화 추이 커스텀 페인터 (HTML 내부의 SVG 정밀 재현)
class ChartPainter extends CustomPainter {
  final bool isDark;
  ChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final textPaint = Paint()..color = Colors.grey;
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..strokeWidth = 1;

    // 가로 가이드라인 그리기
    for (double y in [10, 45, 80, 115]) {
      canvas.drawLine(Offset(20, y), Offset(size.width, y), gridPaint);
    }

    // 체중 블루 선 그리기
    final weightPath = Path()
      ..moveTo(30, 30)..lineTo(80, 42)..lineTo(100, 50)..lineTo(140, 46)
      ..lineTo(175, 60)..lineTo(220, 55)..lineTo(260, 72)..lineTo(300, 68);
    final weightPaint = Paint()
      ..color = FitMateTheme.colorPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(weightPath, weightPaint);

    // 현재 포인터 점 찍기
    canvas.drawCircle(const Offset(300, 68), 5, Paint()..color = FitMateTheme.colorPrimary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TopSummaryCard extends StatelessWidget{
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
        crossAxisAlignment:  CrossAxisAlignment.start,
        children: [
          Text('최근 측정 · ${data.measureDate ?? "-"}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${data.latestWeight ?? "-"}', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('kg', style: TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0x4000BF40), borderRadius: BorderRadius.circular(99)),
                child: Text('${data.weightDelta} kg', style: TextStyle(fontSize: 13, color: data.weightStatus.color, fontWeight: FontWeight.w600)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('근육량', '${data.latestMuscleMass ?? "-"}', 'kg'),
              _buildSummaryItem('체지방률', '${data.latestFatMass ?? "-"}', '%'),
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
            children: [TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70))],
          ),
        )
      ],
    );
  }
}

class DetailMetricsGrid extends StatelessWidget{
  final DashboardResponse data;
  const DetailMetricsGrid({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.6, // 타일의 가로세로 비율 조정
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children:[
          // 실제 백엔드에서 받아온 최신값(latestInfo)을 주입
          _buildMetricTile(context, '체중', '${data.latestWeight} kg', '${data.weightDelta}', data.weightStatus),
          _buildMetricTile(context, '근육량', '${data.latestMuscleMass?? "-"} kg', '${data.muscleDelta}', data.muscleStatus),
          _buildMetricTile(context, '체지방량', '${data.latestFatMass ?? "-"} kg', '${data.fatDelta}', data.fatStatus),
                                
          // 💡 체지방률, BMI, 기초대사량은 현재 백엔드 엔티티에 없으므로, 수식이 완성되기 전까지 우선 기존 더미를 유지하거나 가공합니다.
          _buildMetricTile(context, '체지방률', '21.3 %', '▼ 1.2', ChangeStatus.down),
          _buildMetricTile(context, 'BMI', '22.8', '정상 범위', ChangeStatus.same, isNeu: true),
          _buildMetricTile(context, '기초대사량', '1,648 kcal', '▲ 12', ChangeStatus.up),
        ],
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, String delta, ChangeStatus status, {bool isNeu = false}) {
    final deltaColor = status.color;
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: deltaColor.withOpacity(0.15), borderRadius: BorderRadius.circular(99)),
            child: Text(delta, style: TextStyle(fontSize: 12, color: deltaColor, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

