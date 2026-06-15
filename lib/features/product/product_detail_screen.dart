import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/cart_provider.dart';
import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';
import '../../shared/theme/app_theme.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _tabIndex = 0; // 0: 상품정보, 1: 상세설명, 2: 리뷰

  @override
  Widget build(BuildContext context) {
    final product = MockProducts.findById(widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('상품 상세')),
        body: const Center(child: Text('상품을 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 상단 이미지 + 앱바
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            pinned: true,
            expandedHeight: 320,
            leading: _circleIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => context.pop(),
            ),
            actions: [
              _circleIconButton(
                icon: Icons.favorite_border,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  _circleIconButton(
                    icon: Icons.shopping_bag_outlined,
                    onTap: () => context.go(AppRoutes.cart),
                  ),
                  Consumer(builder: (context, ref, _) {
                    final count = ref.watch(cartCountProvider);
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      top: 4, right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle,
                        ),
                        child: Text('$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 9, color: AppColors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.cardBackground,
                child: Center(
                  child: Icon(
                    _iconForCategory(product.category),
                    size: 96,
                    color: AppColors.premiumPoint,
                  ),
                ),
              ),
            ),
          ),

          // 본문
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 태그
                      if (product.tag != ProductTag.none)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: product.tag == ProductTag.best
                                ? AppColors.primary
                                : AppColors.textMain,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(product.tag.label,
                            style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: AppColors.white, letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      // 상품명
                      Text(product.name, style: AppTextStyles.h2),
                      const SizedBox(height: 8),
                      // 가격
                      Text(product.formattedPrice, style: AppTextStyles.priceLarge),
                      const SizedBox(height: 8),
                      // 평점
                      if (product.reviewCount > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.premiumPoint),
                            const SizedBox(width: 4),
                            Text('${product.rating}', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Text('리뷰 ${product.reviewCount}개', style: AppTextStyles.body2),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // 설명
                      Text(product.description, style: AppTextStyles.body2),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.divider, thickness: 6),

                // 탭
                _DetailTabs(
                  selectedIndex: _tabIndex,
                  reviewCount: product.reviewCount,
                  onSelect: (i) => setState(() => _tabIndex = i),
                ),
                const Divider(height: 1, color: AppColors.border),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildTabContent(product),
                ),

                const SizedBox(height: 100), // 하단바 여백
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        product: product,
        quantity: _quantity,
        onQuantityChange: (q) => setState(() => _quantity = q),
        onAddToCart: () {
          ref.read(cartProvider.notifier).addItem(product, quantity: _quantity);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} ${_quantity}개를 장바구니에 담았습니다.')),
          );
        },
        onBuyNow: () {
          ref.read(cartProvider.notifier).addItem(product, quantity: _quantity);
          context.push(AppRoutes.order);
        },
      ),
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: Icon(icon, size: 16, color: AppColors.textMain),
        ),
      ),
    );
  }

  Widget _buildTabContent(Product product) {
    switch (_tabIndex) {
      case 1:
        return Text(
          product.detailDescription.isEmpty ? '상세 설명이 없습니다.' : product.detailDescription,
          style: AppTextStyles.body1,
        );
      case 2:
        return _ReviewPlaceholder(reviewCount: product.reviewCount, rating: product.rating);
      default:
        return _ProductInfoTable(product: product);
    }
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

// ── 탭 메뉴 ──────────────────────────────
class _DetailTabs extends StatelessWidget {
  final int selectedIndex;
  final int reviewCount;
  final ValueChanged<int> onSelect;

  const _DetailTabs({required this.selectedIndex, required this.reviewCount, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final tabs = ['상품정보', '상세설명', '리뷰($reviewCount)'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final isSelected = selectedIndex == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(tabs[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? AppColors.textMain : AppColors.textSub,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── 상품 정보 테이블 ─────────────────────
class _ProductInfoTable extends StatelessWidget {
  final Product product;
  const _ProductInfoTable({required this.product});

  @override
  Widget build(BuildContext context) {
    final rows = {
      '제조사': product.manufacturer.isEmpty ? '-' : product.manufacturer,
      '원산지': product.origin,
      '배송비': '무료배송',
      '카테고리': product.category.label,
      '재고': product.isSoldOut ? '품절' : '${product.stock}개',
    };

    return Column(
      children: rows.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 80, child: Text(e.key, style: AppTextStyles.body2)),
              Expanded(child: Text(e.value, style: AppTextStyles.body1)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── 리뷰 placeholder ─────────────────────
class _ReviewPlaceholder extends StatelessWidget {
  final int reviewCount;
  final double rating;
  const _ReviewPlaceholder({required this.reviewCount, required this.rating});

  @override
  Widget build(BuildContext context) {
    if (reviewCount == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('아직 작성된 리뷰가 없습니다.', style: AppTextStyles.body2),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.premiumPoint, size: 20),
            const SizedBox(width: 6),
            Text('$rating', style: AppTextStyles.h3),
            const SizedBox(width: 6),
            Text('전체 $reviewCount개의 리뷰', style: AppTextStyles.body2),
          ],
        ),
        const SizedBox(height: 16),
        const Text('리뷰 목록 기능은 추후 업데이트됩니다.', style: AppTextStyles.body2),
      ],
    );
  }
}

// ── 하단 바 (수량 선택 + 버튼) ────────────
class _BottomBar extends StatelessWidget {
  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChange;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _BottomBar({
    required this.product,
    required this.quantity,
    required this.onQuantityChange,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    if (product.isSoldOut) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: null,
            child: const Text('품절된 상품입니다'),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 수량 선택 + 합계
          Row(
            children: [
              _QuantitySelector(
                quantity: quantity,
                onChange: onQuantityChange,
                maxQuantity: product.stock,
              ),
              const Spacer(),
              Text(
                '₩${_formatPrice(product.price * quantity)}',
                style: AppTextStyles.priceLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 버튼
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: onAddToCart,
                    child: const Text('장바구니'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onBuyNow,
                    child: const Text('바로 구매'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ── 수량 선택기 ──────────────────────────
class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChange;
  final int maxQuantity;

  const _QuantitySelector({
    required this.quantity,
    required this.onChange,
    required this.maxQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, () {
            if (quantity > 1) onChange(quantity - 1);
          }),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text('$quantity', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
          ),
          _btn(Icons.add, () {
            if (quantity < maxQuantity) onChange(quantity + 1);
          }),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.textMain),
      ),
    );
  }
}
