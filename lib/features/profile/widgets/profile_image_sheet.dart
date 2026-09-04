import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';


// 프로필 사진을 어디서 가져올지 고르는 바텀시트.
// 항목을 누르면 선택한 ImageSource를 Navigator.pop으로 반환한다. 그냥 닫으면 null.
class ProfileImageSheet extends StatelessWidget{
  const ProfileImageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:  CrossAxisAlignment.start,
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
          Text('프로필 사진 변경',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 12),
          _option(
            context,
            icon: Icons.photo_camera_outlined,
            label: '카메라로 촬영',
            source: ImageSource.camera,
          ),
          const SizedBox(height: 8),
          _option(
            context,
            icon: Icons.photo_library_outlined,
            label: '앨범에서 선택',
            source: ImageSource.gallery,
          ),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,{
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.pop(context, source),
      borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: cs.onSurface),
            const SizedBox(width: 12),
            Text(label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}