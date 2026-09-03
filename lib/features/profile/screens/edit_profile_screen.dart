import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/profile/models/member_profile.dart';
import 'package:fitmate_flutter/features/profile/services/member_api_service.dart';

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

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  bool _saving = false;

  static const int _bioMaxLength = 150;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.introduction ?? '');
    // 타이핑할 때마다 글자수/저장버튼 상태를 다시 그리기 위해
    _nameController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
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

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}