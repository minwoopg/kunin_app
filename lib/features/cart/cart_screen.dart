import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/cart_provider.dart';
import '../../data/models/product_model.dart';
import '../../shared/theme/app_theme.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);

    // 무료배송 기준 (5만원 이상 무료, 미만이면 3,000원)
    const freeShippingThreshold = 50000;
    const shippingFee = 3000;
    final shipping = (cartItems.isEmpty || totalPrice >= freeShippingThreshold) ? 0 : shippingFee;
    final finalPrice = totalPrice + shipping;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('장바구니 (${cartItems.length})'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, ref),
              child: const Text('전체삭제',
                style: TextStyle(fontSize: 13, color: AppColors.textSub),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _EmptyCart(onShopping: () => context.go(AppRoutes.productList))
          : Column(
              children: [
                // 무료배송 안내
                if (shipping > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    color: AppColors.premiumPoint.withOpacity(0.25),
                    child: Text(
                      '₩${_format(freeShippingThreshold - totalPrice)} 더 구매하면 무료배송!',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primaryPressed,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 아이템 리스트
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      return _CartItemCard(
                        item: cartItems[i],
                        onIncrease: () => ref.read(cartProvider.notifier)
                            .increaseQuantity(cartItems[i].product.id),
                        onDecrease: () => ref.read(cartProvider.notifier)
                            .decreaseQuantity(cartItems[i].product.id),
                        onRemove: () => ref.read(cartProvider.notifier)
                            .removeItem(cartItems[i].product.id),
                      );
                    },
                  ),
                ),

                // 결제 정보 + 주문 버튼
                Container(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
                  decoration: const BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PriceRow(label: '상품금액', value: totalPrice),
                      const SizedBox(height: 6),
                      _PriceRow(label: '배송비', value: shipping, isFree: shipping == 0),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppColors.divider),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('총 결제금액', style: AppTextStyles.h3),
                          Text('₩${_format(finalPrice)}', style: AppTextStyles.priceLarge),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: () => context.push(AppRoutes.order),
                          child: Text('${cartItems.length}개 상품 주문하기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('장바구니 비우기', style: AppTextStyles.h3),
        content: const Text('장바구니에 담긴 모든 상품을 삭제하시겠습니까?', style: AppTextStyles.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _format(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ── 빈 장바구니 ──────────────────────────
class _EmptyCart extends StatelessWidget {
  final VoidCallback onShopping;
  const _EmptyCart({required this.onShopping});

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
            child: const Icon(Icons.shopping_bag_outlined, size: 36, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),
          const Text('장바구니가 비어있습니다', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text('원하는 상품을 담아보세요', style: AppTextStyles.body2),
          const SizedBox(height: 28),
          SizedBox(
            width: 180, height: 48,
            child: OutlinedButton(
              onPressed: onShopping,
              child: const Text('쇼핑 계속하기'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 가격 행 ──────────────────────────────
class _PriceRow extends StatelessWidget {
  final String label;
  final int value;
  final bool isFree;
  const _PriceRow({required this.label, required this.value, this.isFree = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body2),
        Text(
          isFree ? '무료' : '₩${_format(value)}',
          style: AppTextStyles.body1.copyWith(
            color: isFree ? AppColors.success : AppColors.textMain,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _format(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ── 장바구니 아이템 카드 ──────────────────
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconForCategory(product.category), color: AppColors.premiumPoint, size: 28),
          ),
          const SizedBox(width: 12),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(product.name,
                        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(product.formattedPrice, style: AppTextStyles.body2),
                const SizedBox(height: 10),

                // 수량 조절 + 합계
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuantityStepper(
                      quantity: item.quantity,
                      onIncrease: onIncrease,
                      onDecrease: onDecrease,
                    ),
                    Text(
                      '₩${_format(item.totalPrice)}',
                      style: AppTextStyles.price,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

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

// ── 수량 조절 (작은 버전) ─────────────────
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, onDecrease),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text('$quantity', style: AppTextStyles.body2.copyWith(
              color: AppColors.textMain, fontWeight: FontWeight.w600,
            )),
          ),
          _btn(Icons.add, onIncrease),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: AppColors.textMain),
      ),
    );
  }
}
