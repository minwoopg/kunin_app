import 'package:flutter/material.dart';
import 'app_outline_button.dart';
import '../theme/app_theme.dart';

/// 빈 상태 공통 위젯
/// (장바구니 비었음 / 주문내역 없음 / 찜 목록 없음 / 검색결과 없음 등에서 재사용)
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Icon(icon, size: 36, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTextStyles.h3),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: AppTextStyles.body2, textAlign: TextAlign.center),
          ],
          if (buttonLabel != null && onButtonTap != null) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: 180,
              child: AppOutlineButton(
                label: buttonLabel!,
                onPressed: onButtonTap,
                height: 48,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 에러 상태 공통 위젯
/// (지금은 백엔드 연동 전이라 사용할 곳이 없지만, API 연동 이후 곧바로 쓸 수 있도록 미리 준비합니다.)
class ErrorStateView extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    this.message = '문제가 발생했습니다.\n잠시 후 다시 시도해주세요.',
    this.buttonLabel = '다시 시도',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, size: 36, color: AppColors.error),
          ),
          const SizedBox(height: 20),
          Text(message, style: AppTextStyles.body2, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              child: AppOutlineButton(
                label: buttonLabel,
                onPressed: onRetry,
                height: 44,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 로딩 상태 공통 위젯
class LoadingStateView extends StatelessWidget {
  final String? message;

  const LoadingStateView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.4,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: AppTextStyles.body2),
          ],
        ],
      ),
    );
  }
}
