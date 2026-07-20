// 로그인 / 회원가입 화면 공통 위젯

import 'package:flutter/material.dart';
import 'package:fitmate_flutter/theme/FitMateTheme.dart';

/// 로그인/회원가입 화면 공통 그라디언트 배경
BoxDecoration fcGradientBackground() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        FitMateTheme.colorPrimary,
        FitMateTheme.colorPrimaryHover,
      ],
    ),
  );
}

/// FitMate 로고 마크: 큰 파란 원(primary) + 작은 초록 원(positive)
class FCMark extends StatelessWidget {
  final double size;
  const FCMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: FitMateTheme.colorPrimary, width: 3),
              ),
            ),
          ),
          Positioned(
            left: size * 0.175,
            top: size * 0.175,
            child: Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: FitMateTheme.colorPositive.withOpacity(0.9),
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 공통 라벨 + 입력필드 (그라디언트 배경 위에 올라가는 반투명 흰 필드)
class FCTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final VoidCallback? onChanged;
  final Widget? errorText;

  const FCTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            onChanged: (_) => onChanged?.call(),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 15),
              filled: true,
              fillColor: Colors.white.withOpacity(0.16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FitMateTheme.radiusSm),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          errorText!,
        ],
      ],
    );
  }
}

/// 흰 배경의 주요 액션 버튼 (로그인, 가입하기)
/// isLoading이 true면 텍스트 대신 로딩 인디케이터를 보여줍니다.
class FCPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const FCPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withOpacity(0.7),
          foregroundColor: FitMateTheme.colorPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: FitMateTheme.colorPrimary,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
      ),
    );
  }
}

/// 카카오 / Apple 소셜 로그인용 아웃라인 버튼
class FCOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const FCOutlinedButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FitMateTheme.radiusMd),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}