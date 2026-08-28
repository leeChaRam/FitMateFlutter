import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/profile/models/member_profile.dart';
import 'package:fitmate_flutter/features/profile/services/member_api_service.dart';

// 프로필 화면 (하단 네비게이션 '설정' 탭)
// 구조 : 상단 타이틀 -> 프로필 카드(사진, 이름, 소개 , 수정 버튼)
//       -> 공개 설정(체중/근육량/체지방률) -> 계정 관리 -> Phase 2 예정 항목
// 진입 시 GET /api/member/me 로 로그인한 회원 정보를 조회해 채운다.

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MemberApiService _memberApiService = MemberApiService();
  late Future<MemberProfile> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = _memberApiService.getMe();
  }

  void _refresh() {
    setState(() {
      _futureProfile = _memberApiService.getMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<MemberProfile>(
          future: _futureProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text('데이터를 불러오지 못했습니다: ${snapshot.error}'));
            }

            final profile = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text('프로필',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  ),

                  // TODO(블록 5): _ProfileHeaderCard 로 교체
                  // TODO(블록 6): _PrivacySection 으로 교체
                  // TODO(블록 7): _AccountSection / _DisabledSection 으로 교체
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHeaderCard(
                          profile: profile,
                          onEdit: () {}, // TODO: 프로필 수정 화면 연결 (다음 단계)
                        ),

                        // 아래 블록 6~7에서 진짜 위젯으로 교체될 임시 텍스트 
                        Text('체중 공개: ${profile.weightPrivacy.label}'),
                        Text('근육량 공개: ${profile.musclePrivacy.label}'),
                        Text('체지방률 공개: ${profile.fatPrivacy.label}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


// 프로필 카드 (사진, 이름, 소개 한 줄,수정 버튼)
class _ProfileHeaderCard extends StatelessWidget {
  final MemberProfile profile;
  final VoidCallback onEdit;

  const _ProfileHeaderCard({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasBio = (profile.introduction?.trim().isNotEmpty ?? false);
    final imageUrl = profile.profileImageUrl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FitMateTheme.radiusLg),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: FitMateTheme.colorPrimary.withOpacity(0.12),
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? NetworkImage(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? Icon(Icons.person, size: 28, color: cs.outlineVariant)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  hasBio ? profile.introduction!.trim() : '자기소개를 등록해보세요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onEdit, 
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              side: BorderSide(color: Colors.grey.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FitMateTheme.radiusSm)),
              foregroundColor: cs.onSurface,
            ),
            child: const Text('수정', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}