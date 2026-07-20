import 'package:flutter/material.dart';
import 'package:fitmate_flutter/widgets/fc_widgets.dart';
import 'package:fitmate_flutter/features/navigation/main_navigation.dart';
import 'package:fitmate_flutter/features/auth/screens/signup.dart';


// TODO: 실제 로그인 API를 쓰는 서비스로 교체하세요.
// import 'package:fitmate_flutter/services/api_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  // final ApiService _apiService = ApiService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: 실제 로그인 API 호출로 교체하세요. 예:
      // final result = await _apiService.login(email, password);
      // 성공하면 result.userId, result.token 등을 로컬(SharedPreferences 등)에 저장.
      await Future.delayed(const Duration(milliseconds: 800)); // 임시 목업

      if (!mounted) return;

      // 로그인 성공 -> 대시보드(메인 탭) 화면으로 이동
      // pushReplacement를 사용해서 로그인 화면으로 뒤로가기 되지 않도록 함
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('로그인에 실패했어요. 이메일/비밀번호를 확인해주세요.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: const [
                    FCMark(),
                    SizedBox(width: 10),
                    Text(
                      'FitMate',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '함께 운동하는 즐거움, 매일 조금씩 이어가요',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 36),
                FCTextField(
                  label: '이메일',
                  controller: _emailCtrl,
                  hint: 'you@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                FCTextField(
                  label: '비밀번호',
                  controller: _passwordCtrl,
                  hint: '비밀번호 입력',
                  obscure: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    child: const Text(
                      '비밀번호를 잊으셨나요?',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FCPrimaryButton(
                  label: '로그인',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.24), height: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('또는',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.24), height: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                FCOutlinedButton(label: '카카오로 계속하기', onPressed: () {}),
                const SizedBox(height: 10),
                FCOutlinedButton(label: 'Apple로 계속하기', onPressed: () {}),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '계정이 없으신가요?',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _goSignup,
                      child: const Text(
                        '회원가입',
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}