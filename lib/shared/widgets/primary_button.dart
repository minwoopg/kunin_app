import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// KIP 공통 Primary 버튼 (골드브라운 채움 버튼)
///
/// 기존에 각 화면마다 따로 만들어 쓰던
/// "ElevatedButton + 로딩 인디케이터 SizedBox" 조합을 표준화한 위젯입니다.
/// 기존 ElevatedButtonTheme을 그대로 사용하므로 색/모양은 자동으로 맞춰집니다.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 52,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.white),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
