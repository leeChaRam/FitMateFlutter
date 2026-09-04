import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/profile/models/member_profile.dart';
import 'package:fitmate_flutter/features/profile/services/member_api_service.dart';
import 'package:fitmate_flutter/features/profile/widgets/profile_image_sheet.dart';
// 기본 정보 수정(이름 자기소개)
// 저장 성공 시 Navigator.pop(context, true) -> 프로필 화면이 재조회로 갱신한다.

class EditProfileScreen extends StatefulWidget{
  final MemberProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final MemberApiService _memberApiService = MemberApiService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  
  String? _imageUrl;
  bool _uploadingImage = false;
  bool _saving = false;

  static const int _imageMaxBytes = 5 * 1024 * 1024;
  static const int _bioMaxLength = 150;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.introduction ?? '');
    // 타이핑할 때마다 글자수/저장버튼 상태를 다시 그리기 위해
    _nameController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
    _imageUrl = widget.profile.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  String get _name => _nameController.text.trim();
  String get _bio => _bioController.text;

  bool get _nameValid => _name.isNotEmpty;
  bool get _bioValid => _bio.length <= _bioMaxLength;

  // 원래 값과 달라진 게 있는지 
  bool get _changed =>
      _name != widget.profile.name || _bio != (widget.profile.introduction ?? '');
  bool get _canSave => !_saving && _changed && _nameValid && _bioValid;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try{
      await _memberApiService.updateBasicInfo(
        name: _name,
        introduction: _bio.trim().isEmpty ? null : _bio.trim(),  
      );
      if (!mounted) return;
      Navigator.pop(context, true); //성공 -> 프로필 화면으로 복귀
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text( '$e'.replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _changePhoto() async {
    // 1) 카메라 / 앨범 선택 
    final source = await showModalBottomSheet<ImageSource>(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FitMateTheme.radiusXl)),
      ),
      builder: (_) => const ProfileImageSheet(),
      );
      if (source == null || !mounted) return;

      // 2) 사진 고르기 (image_picker가 이미지로만 필터링)
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      // 3) 바이트로 읽어 5MB 선검사 (웹/모바일 공통)
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      if (bytes.lengthInBytes > _imageMaxBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 크기는 5MB를 초과할 수 없습니다.')),
        );
        return;
      }
      
      // 4)업로드
      setState(() => _uploadingImage = true);
      try {
        final newUrl = await _memberApiService.uploadProfileImage(
          bytes: bytes,
          filename: picked.name,
        );
        if (!mounted) return;
        setState(() {
          _imageUrl = newUrl;
          _uploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 사진이 변경되었어요')),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _uploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bioLength = _bioController.text.length;
    final bioOver = bioLength > _bioMaxLength;
    
    return Scaffold(
      appBar: AppBar(title: const Text('기본 정보 수정')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---프로필 사진---
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: FitMateTheme.colorPrimary.withOpacity(0.12),
                                backgroundImage: (_imageUrl != null && _imageUrl!.isNotEmpty)
                                    ? NetworkImage(_imageUrl!)
                                    : null,
                                child: (_imageUrl == null || _imageUrl!.isEmpty)
                                    ? Icon(Icons.person, size: 40, color: cs.outlineVariant)
                                    : null,
                              ),
                              if (_uploadingImage)
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black26,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _uploadingImage ? null : _changePhoto,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
                              ),
                              foregroundColor: cs.onSurface,
                            ),
                            child: const Text('사진 변경',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 6),
                          const Text('jpg · png, 최대 5MB',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ---- 이름 ----
                    Row(
                      children: [
                        Text('이름',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                        const SizedBox(width: 2),
                        const Text('*',
                            style: TextStyle(color: FitMateTheme.colorDanger, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: '서클에서 사용할 이름',
                        errorText: _nameValid ? null :'이름을 입력해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---자기소개---
                    Text('자기소개', 
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '어떤 목표로 운동하고 있는지 적어보세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$bioLength/$_bioMaxLength',
                        style: TextStyle(
                          fontSize: 12,
                          color: bioOver ? FitMateTheme.colorDanger : Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      '이름을 바꾸면 서클 피드·댓글 등 서비스 전반에 표시되는 이름이 함께 바뀌어요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                    ),
                  ],   
                ), 
              ),
            ),

            // ---저장 버튼 (하단 고정)---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitMateTheme.colorPrimary,
                    disabledBackgroundColor: cs.outlineVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FitMateTheme.radiusLg),
                    ),
                  ),
                  onPressed: _canSave ? _save : null, 
                  child: _saving
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                    : const Text('저장',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}