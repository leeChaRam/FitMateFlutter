import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/screens/privacy_sheet.dart';

class BodyCompositionInputScreen extends StatefulWidget {
  const BodyCompositionInputScreen({super.key});

  @override
  State<BodyCompositionInputScreen> createState() => _BodyCompositionInputScreenState();
}

class _BodyCompositionInputScreenState extends State<BodyCompositionInputScreen> {
  // 선택된 날짜 상태 (기본값: 오늘)
  DateTime _selectedDate = DateTime.now();

  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  String get _formattedDate {
    return '📅 ${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일';
  }

  String get _formattedSubLabel {
    final weekday = _weekdays[_selectedDate.weekday - 1];
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    return isToday ? '$weekday요일 · 오늘' : '$weekday요일';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5), // 필요에 따라 조정 가능
      lastDate: now, // 오늘 이후(미래) 날짜는 선택 불가
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: FitMateTheme.colorPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
            child: const Text('저장', style: TextStyle(color: FitMateTheme.colorPrimary, fontWeight: FontWeight.bold, fontSize: 16),)
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
                      Text(_formattedDate, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      Text(_formattedSubLabel, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  TextButton(onPressed: _pickDate, child: const Text('변경', style: TextStyle(color: FitMateTheme.colorPrimary),))
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