import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/address_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../data/models/address_model.dart';
import '../../data/models/product_model.dart';
import '../../shared/theme/app_theme.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final _nameController    = TextEditingController();
  final _phoneController   = TextEditingController();
  final _addressController = TextEditingController();
  final _requestController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 저장된 배송지 중 기본 배송지를 초기값으로 채웁니다.
    final defaultAddress = ref.read(defaultAddressProvider);
    if (defaultAddress != null) {
      _nameController.text = defaultAddress.receiverName;
      _phoneController.text = defaultAddress.phone;
      _addressController.text = defaultAddress.fullAddress;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _requestController.dispose();
    super.dispose();
  }

  /// 저장된 배송지 목록에서 다른 배송지를 선택합니다.
  /// (배송지 자체를 관리/추가하려면 마이페이지 > 배송지 관리를 이용합니다.)
  Future<void> _selectAddress() async {
    final selected = await context.push<Address>('${AppRoutes.addressList}?select=true');
    if (selected != null && mounted) {
      setState(() {
        _nameController.text = selected.receiverName;
        _phoneController.text = selected.phone;
        _addressController.text = selected.fullAddress;
      });
    }
  }

  Future<void> _onSubmitOrder(List<CartItem> items, int productPrice, int shippingFee) async {
    if (items.isEmpty) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600)); // 임시 처리 딜레이

    // 주문 생성과 장바구니 비우기 모두 이제 Repository를 거치는 비동기 작업입니다.
    // (Mock이라 사실상 즉시 끝나지만, 실제 API에서는 진짜로 기다려야 하는 부분이라
    //  await로 순서를 명확히 해둡니다.)
    await ref.read(orderProvider.notifier).createOrder(
      items: items,
      productPrice: productPrice,
      shippingFee: shippingFee,
      receiverName: _nameController.text,
      receiverPhone: _phoneController.text,
      address: _addressController.text,
    );
    await ref.read(cartProvider.notifier).clear();

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // 주문 완료 화면으로 (스택 정리: 뒤로가기 시 장바구니/상세로 안 돌아가도록)
    context.go(AppRoutes.orderComplete);
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final productPrice = ref.watch(cartTotalPriceProvider);

    const freeShippingThreshold = 50000;
    const shippingFeeAmount = 3000;
    final shippingFee = (productPrice >= freeShippingThreshold || productPrice == 0) ? 0 : shippingFeeAmount;
    final totalPrice = productPrice + shippingFee;

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('주문/결제')),
        body: const Center(child: Text('주문할 상품이 없습니다.', style: AppTextStyles.body2)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('주문/결제')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배송지 정보
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('배송지 정보', style: AppTextStyles.h3),
                        GestureDetector(
                          onTap: _selectAddress,
                          child: Text('변경',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(_nameController.text, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text('(${_phoneController.text})', style: AppTextStyles.body2),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_addressController.text, style: AppTextStyles.body2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 배송 요청사항
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('배송 요청사항', style: AppTextStyles.h3),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _requestController,
                      style: AppTextStyles.body2,
                      decoration: const InputDecoration(
                        hintText: '예) 부재 시 경비실에 맡겨주세요',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 주문 상품
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('주문 상품 (${cartItems.fold<int>(0, (s, i) => s + i.quantity)})', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    for (int i = 0; i < cartItems.length; i++) ...[
                      _OrderItemRow(item: cartItems[i]),
                      if (i != cartItems.length - 1) const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppColors.divider),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 결제 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('결제 정보', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _PriceRow(label: '상품금액', value: productPrice),
                    const SizedBox(height: 6),
                    _PriceRow(label: '배송비', value: shippingFee, isFree: shippingFee == 0),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.divider),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('총 결제금액', style: AppTextStyles.h3),
                        Text('₩${_format(totalPrice)}', style: AppTextStyles.priceLarge),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 결제 안내
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.premiumPoint.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primaryPressed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '결제 시스템은 추후 연동될 예정입니다. 현재는 주문 정보만 저장됩니다.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primaryPressed),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _onSubmitOrder(cartItems, productPrice, shippingFee),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                  )
                : Text('₩${_format(totalPrice)} 주문하기'),
          ),
        ),
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

// ── 주문 상품 행 ──────────────────────────
class _OrderItemRow extends StatelessWidget {
  final CartItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_iconForCategory(product.category), color: AppColors.premiumPoint, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: AppTextStyles.body2.copyWith(color: AppColors.textMain),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${product.formattedPrice} x ${item.quantity}', style: AppTextStyles.caption),
            ],
          ),
        ),
        Text('₩${_format(item.totalPrice)}', style: AppTextStyles.price),
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
