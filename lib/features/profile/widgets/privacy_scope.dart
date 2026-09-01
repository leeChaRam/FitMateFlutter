import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/profile/models/member_profile.dart';

// 지표 하나의 공개 범위를 고르면 바텀시트.
// title 지표명, current 현재 설정값 
// 확인을 누르면 선택한 PrivacyScope를 Navigator.pop으로 반환한다. 
// 그냥 닫으면 null이 반환된다. 
class PrivacyScopeSheet extends StatefulWidget {
  final String title;
  final PrivacyScope current;

  const PrivacyScopeSheet({super.key, required this.title, required this.current});

  @override
  State<PrivacyScopeSheet> createState() => _PrivacyScopeSheetState();
}

class _PrivacyScopeSheetState extends State<PrivacyScopeSheet> {
  late PrivacyScope _selected = widget.current;

  // 옵션별 설명 문구
  static const Map<PrivacyScope, String> _descriptions = {
    PrivacyScope.onlyMe: '친구들에게 전혀 공개하지 않아요',
    PrivacyScope.delta: '절댓값 대신 증감(▲▼)만 보여요',
    PrivacyScope.group: '서클 친구들 모두에게 수치가 그대로 보여요',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('${widget.title} 공개 설정',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 2),
          const Text('서클 친구들에게 어떻게 보여줄까요?',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),

          for (final scope in PrivacyScope.values) ...[
            _buildOptionCard(scope),
            if (scope != PrivacyScope.values.last) const SizedBox(height: 8),
          ],

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text('설정은 언제든 변경할 수 있어요. 기존 기록에도 바로 반영돼요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FitMateTheme.colorPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FitMateTheme.radiusLg),
                ),
              ),
              onPressed: () => Navigator.pop(context, _selected),
              child: const Text('확인',
                  style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(PrivacyScope scope) {
    final isSelected = _selected == scope;
    return GestureDetector(
      onTap: () => setState(() => _selected = scope),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? FitMateTheme.colorPrimary.withOpacity(0.06)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
          border: Border.all(
            color: isSelected ? FitMateTheme.colorPrimary : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? FitMateTheme.colorPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? FitMateTheme.colorPrimary : Colors.grey,
                  width: 1.5,
                ),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scope.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? FitMateTheme.colorPrimary : null,
                      )),
                  const SizedBox(height: 1),
                  Text(_descriptions[scope] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}