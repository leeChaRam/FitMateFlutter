import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';

class WeightPrivacyBottomSheet extends StatefulWidget{
const WeightPrivacyBottomSheet({super.key});

  @override
  State<WeightPrivacyBottomSheet> createState() => _WeightPrivacyBottomSheetState();
}

class _WeightPrivacyBottomSheetState extends State<WeightPrivacyBottomSheet>{
  int _selectedOption = 1; // HTML상 기본 선택값인 '변화량 만 공개' 지정

  @override
  Widget build(BuildContext context){
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 12, left: 16, right: 16),// 키보드가 올라오는 만큼 위젯이 안전하게 위로 스윽 밀려 올라가서 키보드 바로 위에 안착하는 코드 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //상단 핸들 바
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16,),
          Text('⚖️ 체중 공개 설정', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const Text('서클 친구들에게 어떻게 보여줄까요?', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),

          //옵션 카드 리스트
          _buildOptionCard(0, '🔒 나만 보기', '친구들에게 전혀 공개하지 않아요', Colors.grey),
          const SizedBox(height: 8),
          _buildOptionCard(1, '📈 변화량만 공개', '절댓값 대신 ▲▼ 증감만 보여요 (기본값)', FitMateTheme.colorPrimary),
          const SizedBox(height: 8),
          _buildOptionCard(2, '👥 그룹 전체 공개', '서클 친구들 모두에게 수치가 보여요', Colors.grey),
          const SizedBox(height: 16),

          //가이드 노트 타입
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(FitMateTheme.radiusSm)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡 ', style: TextStyle(fontSize: 14)),
                Expanded(child: Text('설정은 언제든 변경할 수 있어요. 기존 기록에도 바로 반영돼요.', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4))),
              ],
            )
          ),
          const SizedBox(height: 16,),

          //확인 버튼 
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FitMateTheme.colorPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(FitMateTheme.radiusLg)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildOptionCard(int index, String title, String subtitle, Color activeColor){
    final isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? FitMateTheme.colorPrimary.withOpacity(0.06) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
          border: Border.all(color: isSelected ? FitMateTheme.colorPrimary : Colors.grey.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? FitMateTheme.colorPrimary : Colors.transparent,
                border: Border.all(color: isSelected ? FitMateTheme.colorPrimary :  Colors.grey, width: 1.5),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white): null,
            ),
            const SizedBox(width: 14,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSelected ? FitMateTheme.colorPrimary : null),),
                  const SizedBox(height: 1,),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
          ],
        )
      )
    );
  }
}