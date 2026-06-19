import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/screens/input_screen.dart';

class BodyCompositionsDashboard extends StatelessWidget {
  const BodyCompositionsDashboard({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최신 측정 요약 그라데이션 카드 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [FitMateTheme.colorPrimary, Color(0xff6541F2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:  BorderRadius.circular(FitMateTheme.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('최근 측정 · 2025.05.28', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      // alignment: Alignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('68.4', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
                        const Text('kg', style: TextStyle(fontSize: 16, color: Colors.white70)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0x4000BF40), borderRadius: BorderRadius.circular(99)),
                          child: const Text('▼ 0.8 kg', style: TextStyle(fontSize: 13, color: Color(0xff7DF5A5), fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem('근육량', '34.1', 'kg'),
                        _buildSummaryItem('체지방률', '21.3', '%'),
                        _buildSummaryItem('BMI', '22.8', ''),
                      ],
                    )
                  ],
                ),
              ),
            ),

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
                    ],
                  ),
                ),
              ),
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              mainAxisExtent: 8,
              crossAxisSpacing: 8,
              children: [
                _buildMetricTile(context, '체중', '68.4 kg', '▼ 0.8', FitMateTheme.colorDanger),
                _buildMetricTile(context, '근육량', '34.1 kg', '▲ 0.3', FitMateTheme.colorPositive),
                _buildMetricTile(context, '체지방량', '14.6 kg', '▼ 1.1', FitMateTheme.colorDanger),
                _buildMetricTile(context, '체지방률', '21.3 %', '▼ 1.2', FitMateTheme.colorDanger),
                _buildMetricTile(context, 'BMI', '22.8', '정상 범위', cs.outline, isNeu: true),
                _buildMetricTile(context, '기초대사량', '1,648 kcal', '▲ 12', FitMateTheme.colorPositive),
              ],
            ),

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

  Widget _buildMetricTile(BuildContext context, String label, String value, String delta, Color deltaColor, {bool isNeu = false}) {
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

