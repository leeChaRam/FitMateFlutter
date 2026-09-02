import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/profile/models/member_profile.dart';
import 'package:fitmate_flutter/features/profile/services/member_api_service.dart';
import 'package:fitmate_flutter/features/profile/widgets/privacy_scope.dart';

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
  // 지표 → 현재 공개범위
  PrivacyScope _scopeOf(MemberProfile p, PrivacyMetric m) {
    switch (m) {
      case PrivacyMetric.weight:
        return p.weightPrivacy;
      case PrivacyMetric.muscle:
        return p.musclePrivacy;
      case PrivacyMetric.fat:
        return p.fatPrivacy;
    }
  }

  // 공개범위 시트 열기 -> 저장 -> 화면 갱신
  Future<void> _editPrivacy(PrivacyMetric metric, MemberProfile profile) async {
    final current = _scopeOf(profile, metric);

    final picked = await showModalBottomSheet<PrivacyScope>(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FitMateTheme.radiusXl)),
      ),
      builder:  (_) => PrivacyScopeSheet(title: metric.label, current: current),
    );

    // 취소했거나(=null) 값이 그대로면 아무것도 안함
    if (!mounted || picked == null || picked == current) return;

    // 세 값을 현재 프로필 기준으로 준비하고, 방금 고른 지표만 교체
    var weight = profile.weightPrivacy;
    var muscle = profile.musclePrivacy;
    var fat = profile.fatPrivacy;
    switch (metric) {
      case PrivacyMetric.weight:
        weight = picked;
        break;
      case PrivacyMetric.muscle:
        muscle = picked;
        break;
      case PrivacyMetric.fat:
        fat = picked;
        break;
    }

    try{
      final updated = await _memberApiService.updatePrivacy(
        weight: weight, 
        muscle: muscle, 
        fat: fat,
      );
      if (!mounted) return;
      setState(() {
        _futureProfile = Future.value(updated); // 서버가 준 최신 정보로 즉시 갱신
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:  Text('$e'.replaceFirst('Exception: ', ''))),
      );
    }
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
                          onEdit: () {}, // TODO: 프로필 수정 화면 (다음 단계)
                        ),
                        const SizedBox(height: 20),
                        _PrivacySection(
                          profile: profile,
                          onEdit: (metric) => _editPrivacy(metric, profile), // TODO: 공개범위 바텀시트 (다음 단계)
                        ),
                        const Divider(height: 32),
                        _AccountSection(
                          onChangePassword: () {}, // TODO
                          onLogout: () {},         // TODO
                          onWithdraw: () {},       // TODO
                        ),
                        const Divider(height: 24),
                        const _DisabledSection(),
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

// 공개 설정 (체중/ 근육량 / 체지방률)
// 각 행을 누르면 공개 범위 선택 바텀시트가 열린다.

class _PrivacySection extends StatelessWidget {
  final MemberProfile profile;
  final void Function(PrivacyMetric metric) onEdit;

  const _PrivacySection({required this.profile, required this.onEdit});

  @override 
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text('공개 설정',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        _PrivacyRow(
          label: '체중', 
          scope: profile.weightPrivacy, 
          onTap: () => onEdit(PrivacyMetric.weight),
        ),
        _PrivacyRow(
          label: '근육량', 
          scope: profile.musclePrivacy, 
          onTap: () => onEdit(PrivacyMetric.muscle),
        ),
        _PrivacyRow(
          label: '체지방률', 
          scope: profile.fatPrivacy, 
          onTap: () => onEdit(PrivacyMetric.fat),
        ),
      ],
    );
  }
}
class _PrivacyRow extends StatelessWidget {
  final String label;
  final PrivacyScope scope;
  final VoidCallback onTap;

  const _PrivacyRow({required this.label, required this.scope, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    //공개 범위별 배지 색상
    late final Color badgeBg;
    late final Color badgeFg;
    switch (scope) {
      case PrivacyScope.onlyMe:
        badgeBg = Colors.grey.withOpacity(0.12);
        badgeFg = Colors.grey;
        break;
      case PrivacyScope.delta:
        badgeBg = FitMateTheme.colorPositive.withOpacity(0.12);
        badgeFg = FitMateTheme.colorPositive;
        break;
      case PrivacyScope.group:
        badgeBg = FitMateTheme.colorPrimary.withOpacity(0.12);
        badgeFg = FitMateTheme.colorPrimary;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 16, color: cs.onSurface)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999)
              ),
              child: Text(scope.label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: badgeFg)),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: cs.outlineVariant),
          ],
        )
      )
    );
  }
}

// 계정 관리 (비밀번호 변경, 로그아웃, 회원 탈퇴)
class _AccountSection extends StatelessWidget {
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;
  final VoidCallback onWithdraw;

  const _AccountSection({
    required this.onChangePassword,
    required this.onLogout,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Text('계정 관리', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        _AccountRow(label: '비밀번호 변경', onTap: onChangePassword),
        _AccountRow(label: '로그아웃', onTap: onLogout),
        _AccountRow(label: '회원 탈퇴', color: FitMateTheme.colorDanger, onTap: onWithdraw),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget{
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _AccountRow({required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 15, color: color ?? cs.onSurface)),
            ),
            Icon(Icons.chevron_right, size: 20, color: cs.outlineVariant),
          ],
        ),
      ),
    );
  }
}

// Phase 2 예정 항목 (비활성, 안내만)

class _DisabledSection extends StatelessWidget {
  const _DisabledSection();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Column(
        children: const[
          _DisabledRow(label: '알림 / 리마인더 설정'),
          _DisabledRow(label: '운동 관리'),
        ]
      ),
    );
  }
}

class _DisabledRow extends StatelessWidget {
  final String label;
  const _DisabledRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 15, color: cs.onSurface)),
                const SizedBox(height: 2),
                const Text('Phase 2에서 제공될 예정이에요',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: cs.outlineVariant),
        ],
      ),
    );
  }
}
