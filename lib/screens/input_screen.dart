import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/screens/privacy_sheet.dart';
import 'package:fitmate_flutter/services/api_service.dart';

class BodyCompositionInputScreen extends StatefulWidget {
  const BodyCompositionInputScreen({super.key});

  @override
  State<BodyCompositionInputScreen> createState() => _BodyCompositionInputScreenState();
}

class _BodyCompositionInputScreenState extends State<BodyCompositionInputScreen> {
  final ApiService _apiService = ApiService();

  // TODO: 로그인/전역 상태 연동되면 실제 로그인한 사용자의 memberId로 교체할 것
  static const int _memberId = 1;

  // 선택된 날짜 상태 (기본값: 오늘)
  DateTime _selectedDate = DateTime.now();
  
  // 입력 필드 컨트롤러 (초기값 없이 비워둠)
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _muscleMassController = TextEditingController();
  final TextEditingController _fatMassController = TextEditingController();

  bool _isSaving = false;

  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _muscleMassController.dispose();
    _fatMassController.dispose();
    super.dispose();
  }

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

  // 서버로 보낼 날짜 포맷 (yyyy-MM-dd, LocalDate와 매칭)
  String get _isoDate {
    final y = _selectedDate.year.toString().padLeft(4, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final d = _selectedDate.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5), // 필요에 따라 조정 가능
      lastDate: now, // 오늘 이후(미래) 날짜는 선택 불가
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

   void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveRecord() async {
    // 숫자 파싱 (빈 칸이면 null 처리)
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final muscleMass = double.tryParse(_muscleMassController.text.trim());
    final fatMass = double.tryParse(_fatMassController.text.trim());

    // 체중은 필수 정보이므로 최소한의 검정 
    if (weight == null) {
      _showSnackBar('체중을 입력해주세요.');
      return;
    }

    setState(() => _isSaving = true);

    try{
      await _apiService.postBodyInfo(
        memberId: _memberId, 
        measureDate: _isoDate, 
        weight: weight,
        height: height,
        muscleMass: muscleMass,
        fatMass: fatMass,
      );

      if(!mounted) return;
      _showSnackBar('기록이 저장되었습니다.');
      Navigator.pop(context, true);
    } catch (e) {
      if(!mounted) return;
      _showSnackBar('저장에 실패했습니다. 다시 시동해주세요.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            onPressed: _isSaving ? null : _saveRecord,
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
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
              child: Column(
                children: [
                  _buildInputRow('⚖️', '체중', _weightController, 'kg'),
                  _buildInputRow('📏', '키', _heightController, 'cm'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('체성분'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusLg)),
              child: Column(
                children: [
                  _buildInputRow('💪', '근육량', _muscleMassController, 'kg'),
                  _buildInputRow('🔥', '체지방량', _fatMassController, 'kg'),
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
                onPressed: _isSaving ? null : _saveRecord,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('기록 저장하기', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),)
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

  Widget _buildInputRow(String emoji, String label, TextEditingController controller, String unit){
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
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: FitMateTheme.colorPrimary, fontWeight: FontWeight.bold, fontSize: 17),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '0.0',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
              ),
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