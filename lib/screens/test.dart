import 'package:flutter/material.dart';
import 'package:fitmate_flutter/widgets/fc_widgets.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';
import 'package:fitmate_flutter/features/auth/services/auth_api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthApiService _authApiService = AuthApiService();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  DateTime? _birth;
  bool _agree = false;
  bool _isLoading = false;

  // 이메일 형식 검사 (예: someone@example.com, someone@school.ac.kr)
  // 도메인에 점(.)이 여러 개 들어가는 다단계 도메인(.ac.kr, .co.kr 등)도 허용합니다.
  final RegExp _emailPattern =
      RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)*\.[a-zA-Z]{2,}$');

  // 비밀번호 정책: 영문 + 숫자 + 특수문자 모두 포함, 8~20자
  // (백엔드 MemberJoinRequest / MemberService의 정책과 동일하게 맞췄습니다)
  final RegExp _passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_\-+=\[\]{}|;:,.<>/?]).{8,20}$',
  );

  bool get _emailInvalid =>
      _emailCtrl.text.isNotEmpty && !_emailPattern.hasMatch(_emailCtrl.text.trim());

  bool get _passwordInvalid =>
      _passwordCtrl.text.isNotEmpty && !_passwordPattern.hasMatch(_passwordCtrl.text);

  bool get _confirmMismatch =>
      _passwordConfirmCtrl.text.isNotEmpty &&
      _passwordCtrl.text != _passwordConfirmCtrl.text;

  bool get _heightInvalid {
    final text = _heightCtrl.text.trim();
    if (text.isEmpty) return false; // 비어있는 건 '_signupDisabled'에서 별도 체크
    final parsed = double.tryParse(text);
    return parsed == null || parsed <= 0;
  }

  bool get _signupDisabled {
    return _emailCtrl.text.isEmpty ||
        _emailInvalid ||
        _passwordCtrl.text.isEmpty ||
        _passwordInvalid ||
        _passwordConfirmCtrl.text.isEmpty ||
        _confirmMismatch ||
        _nameCtrl.text.isEmpty ||
        _birth == null ||
        _heightCtrl.text.trim().isEmpty ||
        _heightInvalid ||
        !_agree;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1930),
      lastDate: now,
    );
    if (picked != null) setState(() => _birth = picked);
  }

  /// DateTime -> 'yyyy-MM-dd' 문자열 (백엔드 LocalDate 형식과 동일)
  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _submit() async {
    if (_birth == null) return; // _signupDisabled에서 이미 막고 있지만 방어적으로 체크

    setState(() => _isLoading = true);
    try {
      await _authApiService.join(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        checkPassword: _passwordConfirmCtrl.text,
        name: _nameCtrl.text.trim(),
        birthDate: _formatDate(_birth!),
        height: double.parse(_heightCtrl.text.trim()),
      );

      if (!mounted) return;

      // 가입 성공 -> 로그인 화면으로 돌아가서 로그인 하도록 유도
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가입이 완료됐어요. 로그인해주세요.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goLogin() {
    Navigator.of(context).pop();
  }

  /// 그라디언트 배경 위에서도 잘 보이도록 danger 색을 흰색과 살짝 섞은 에러 문구
  Widget _errorText(String message) {
    return Text(
      message,
      style: TextStyle(
        color: Color.lerp(FitMateTheme.colorDanger, Colors.white, 0.35),
        fontSize: 13,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: fcGradientBackground(),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goLogin,
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    ),
                    const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              // 스크롤 폼
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FitMate에서 함께할 프로필을 만들어요',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      FCTextField(
                        label: '이메일',
                        controller: _emailCtrl,
                        hint: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: () => setState(() {}),
                        errorText: _emailInvalid
                            ? _errorText('올바른 이메일 형식이 아니에요')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      FCTextField(
                        label: '비밀번호',
                        controller: _passwordCtrl,
                        hint: '영문, 숫자, 특수문자 포함 8~20자',
                        obscure: true,
                        onChanged: () => setState(() {}),
                        errorText: _passwordInvalid
                            ? _errorText('영문, 숫자, 특수문자를 모두 포함한 8~20자여야 해요')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      FCTextField(
                        label: '비밀번호 확인',
                        controller: _passwordConfirmCtrl,
                        hint: '비밀번호 다시 입력',
                        obscure: true,
                        onChanged: () => setState(() {}),
                        errorText: _confirmMismatch
                            ? _errorText('비밀번호가 일치하지 않아요')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      FCTextField(
                        label: '이름(닉네임)',
                        controller: _nameCtrl,
                        hint: 'FitMate에서 사용할 이름',
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      // 생년월일
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '생년월일',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
                            onTap: _pickBirth,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _birth == null
                                    ? 'YYYY-MM-DD'
                                    : '${_birth!.year}-${_birth!.month.toString().padLeft(2, '0')}-${_birth!.day.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: _birth == null ? Colors.white54 : Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FCTextField(
                        label: '키 (cm)',
                        controller: _heightCtrl,
                        hint: '170',
                        keyboardType: TextInputType.number,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              value: _agree,
                              onChanged: (v) => setState(() => _agree = v ?? false),
                              fillColor: WidgetStateProperty.resolveWith((states) => Colors.white),
                              checkColor: FitMateTheme.colorPrimary,
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '이용약관 및 개인정보 처리방침에 동의합니다',
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 하단 고정 영역
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.24))),
                ),
                child: Column(
                  children: [
                    FCPrimaryButton(
                      label: '가입하기',
                      onPressed: _signupDisabled ? null : _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '이미 계정이 있으신가요?',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _goLogin,
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}