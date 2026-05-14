import 'package:flutter/material.dart';

class BodyInputScreen extends StatefulWidget {
  const BodyInputScreen({super.key});

  @override
  State<BodyInputScreen> createState() => _BodyInputScreenState();
}

class _BodyInputScreenState extends State<BodyInputScreen> {
  // 입력값을 제어하기 위한 컨트롤러들
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _muscleController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 컨트롤러 해제
    _weightController.dispose();
    _muscleController.dispose();
    _fatController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 25),
            _buildLabel("측정일"),
            _buildDatePickerField(),
            const SizedBox(height: 20),
            _buildLabel("체중"),
            _buildNumberInput(_weightController, "73.2", Colors.blue),
            const SizedBox(height: 20),
            _buildLabel("근육량"),
            _buildNumberInput(_muscleController, "35.8", Colors.green),
            const SizedBox(height: 20),
            _buildLabel("체지방량"),
            _buildNumberInput(_fatController, "18.4", Colors.orange),
            const SizedBox(height: 20),
            _buildLabel("메모 (선택)"),
            _buildMemoField(),
            const SizedBox(height: 40),
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 상단 안내 카드
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Text(
            "오늘 측정한 인바디 수치를 입력하세요",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 항목 이름 라벨
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
      ),
    );
  }

  // 날짜 선택 필드
  Widget _buildDatePickerField() {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: "2026년 5월 4일 (일)",
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 숫자 입력 필드 (색상별 테두리 적용)
  Widget _buildNumberInput(TextEditingController controller, String hint, Color color) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      decoration: InputDecoration(
        hintText: hint,
        suffixText: "kg",
        suffixStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // 메모 입력 필드
  Widget _buildMemoField() {
    return TextField(
      controller: _memoController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "예: 치팅데이 다음날, 운동 3개월 차...",
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 저장 버튼
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          print("체중: ${_weightController.text}");
          // 여기서 서버 연동 로직 호출
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A6BFF),
          shape: BorderRadius.circular(15),
          elevation: 0,
        ),
        child: const Text(
          "기록 저장 및 서클 공유",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}