import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/screens/privacy_sheet.dart';

class BodyCompositionInputScreen extends StatelessWidget {
  const BodyCompositionInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // Start AppBar ///
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('취소', style: TextStyle(color: FitMateTheme.colorPrimary, fontSize: 16)),
        ),
        title: const Text('체성분 기록', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {}, 
            child: const Text('저장',style: TextStyle(color: FitMateTheme.colorPrimary, fontWeight: FontWeight.bold, fontSize: 16),)
          )
        ],
      ),
      // Start body //
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //날짜 피커 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(FitMateTheme.radiusMd)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📅 2025년 5월 28일', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      const Text('수요일 · 오늘', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  TextButton(onPressed: () {}, child: const Text('변경', style: TextStyle(color: FitMateTheme.colorPrimary),))
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('필수 정보'),
            _buildInputRow('⚖️', '체중', '68.4', 'kg'),
            const SizedBox(height: 16),

            _buildSectionTitle('체성분'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
              child: Column(
                children: [
                  _buildInputRow('💪', '근육량', '34.1', 'kg'),
                  _buildInputRow('🔥', '체지방량', '14.6', 'kg'),
                  _buildInputRow('📊', '체지방률', '21.3', '%'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('공개 설정'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
              child: Column(
                children: [
                  _buildPrivacyRow(context, '체중', '변화량만', FitMateTheme.colorPositive),
                  _buildPrivacyRow(context, '근육량', '친구 공개', FitMateTheme.colorPrimary),
                  _buildPrivacyRow(context, '체지방', '나만 보기', Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 24),

            //하단 액션 버튼 
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitMateTheme.colorPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(FitMateTheme.radiusLg)),
                ),
                onPressed: () {}, 
                child: const Text('기록 저장하기', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),)
              ),
            )
          ],
        ),
      )
    );
  
}

  Widget _buildSectionTitle(String title){
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey))
    );
  }

  Widget _buildInputRow(String emoji, String label, String value, String unit){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              controller: TextEditingController(text: value),
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: FitMateTheme.colorPrimary, fontWeight: FontWeight.bold, fontSize: 17),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
          ),
        const SizedBox(width: 4),
        Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPrivacyRow(BuildContext context, String label, String tag, Color color){
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(99)),
            child: Text(tag, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: (){
        //체중 행 클릭 시 바텀 시트 호출 
        if(label == '체중'){
          showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(FitMateTheme.radiusXl))),
            builder: (_) => const WeightPrivacyBottomSheet(),
          );
        }
      },
    );
  }
}