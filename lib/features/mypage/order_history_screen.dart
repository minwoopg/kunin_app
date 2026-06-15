import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/order_provider.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../shared/theme/app_theme.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('주문 내역')),
      body: orders.isEmpty
          ? _EmptyOrders(onShopping: () => context.go(AppRoutes.productList))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _OrderCard(
                order: orders[i],
                onCancel: () => _showCancelDialog(context, ref, orders[i].id),
              ),
            ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('주문 취소', style: AppTextStyles.h3),
        content: const Text('이 주문을 취소하시겠습니까?', style: AppTextStyles.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              ref.read(orderProvider.notifier).cancelOrder(orderId);
              Navigator.pop(context);
            },
            child: const Text('주문 취소', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── 빈 주문내역 ──────────────────────────
class _EmptyOrders extends StatelessWidget {
  final VoidCallback onShopping;
  const _EmptyOrders({required this.onShopping});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: const Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),
          const Text('주문 내역이 없습니다', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text('첫 주문을 시작해보세요', style: AppTextStyles.body2),
          const SizedBox(height: 28),
          SizedBox(
            width: 180, height: 48,
            child: OutlinedButton(
              onPressed: onShopping,
              child: const Text('쇼핑하러 가기'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 주문 카드 ──────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onCancel;

  const _OrderCard({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.first;
    final extraCount = order.items.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 날짜 + 상태
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDate(order.orderedAt), style: AppTextStyles.body2),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),

          // 상품 정보
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_iconForCategory(firstItem.product.category),
                  color: AppColors.premiumPoint, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extraCount > 0
                          ? '${firstItem.product.name} 외 $extraCount건'
                          : firstItem.product.name,
                      style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('총 ${order.totalQuantity}개', style: AppTextStyles.body2),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),

          // 주문번호 + 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('주문번호 ${order.id}', style: AppTextStyles.caption),
              Text(order.formattedTotalPrice, style: AppTextStyles.price),
            ],
          ),

          // 취소 버튼
          if (order.status == OrderStatus.pending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 42,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSub,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('주문 취소'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${_pad(date.month)}.${_pad(date.day)} ${_pad(date.hour)}:${_pad(date.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  IconData _iconForCategory(ProductCategory category) {
    switch (category) {
      case ProductCategory.medicalDevice: return Icons.medical_services_outlined;
      case ProductCategory.diagnostic:    return Icons.biotech_outlined;
      case ProductCategory.beautyCare:    return Icons.spa_outlined;
      case ProductCategory.medicine:      return Icons.medication_outlined;
      case ProductCategory.health:        return Icons.health_and_safety_outlined;
    }
  }
}

// ── 상태 뱃지 ──────────────────────────────
class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OrderStatus.pending   => (AppColors.premiumPoint.withOpacity(0.3), AppColors.primaryPressed),
      OrderStatus.preparing => (AppColors.primary.withOpacity(0.15), AppColors.primary),
      OrderStatus.shipping  => (const Color(0xFFE3F2E8), AppColors.success),
      OrderStatus.delivered => (AppColors.divider, AppColors.textSub),
      OrderStatus.cancelled => (AppColors.error.withOpacity(0.1), AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
