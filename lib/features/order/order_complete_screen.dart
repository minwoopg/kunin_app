import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/order_provider.dart';
import '../../shared/theme/app_theme.dart';

class OrderCompleteScreen extends ConsumerWidget {
  const OrderCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(latestOrderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 완료 아이콘
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 64, height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: AppColors.white, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('주문이 완료되었습니다', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                '주문해주셔서 감사합니다.\n주문 내역은 마이페이지에서 확인할 수 있습니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body2,
              ),

              const SizedBox(height: 32),

              // 주문 정보 카드
              if (order != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      _infoRow('주문번호', order.id),
                      const SizedBox(height: 10),
                      _infoRow('주문상품', '${order.items.first.product.name}'
                          '${order.items.length > 1 ? ' 외 ${order.items.length - 1}건' : ''}'),
                      const SizedBox(height: 10),
                      _infoRow('총 수량', '${order.totalQuantity}개'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.divider),
                      ),
                      _infoRow('총 결제금액', order.formattedTotalPrice, isBold: true),
                    ],
                  ),
                ),

              const Spacer(flex: 3),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.orderHistory),
                        child: const Text('주문내역 보기'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: const Text('홈으로'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body2),
        Text(value,
          style: isBold
              ? AppTextStyles.priceLarge
              : AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
