import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/cart_provider.dart';
import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';
import '../../shared/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final newProducts = MockProducts.all
        .where((p) => p.tag == ProductTag.newItem)
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'KIP 2026',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textMain),
            onPressed: () => context.push(AppRoutes.search),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textMain),
                onPressed: () => context.go(AppRoutes.cart),
              ),
              if (cartCount > 0)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text('$cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9, color: AppColors.white, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 메인 배너
              _MainBanner(onTap: () => context.go(AppRoutes.productList)),
              const SizedBox(height: 28),

              // 카테고리 바로가기
              _CategorySection(
                onSelect: (cat) => context.go(AppRoutes.productListWithCategory(cat)),
              ),
              const SizedBox(height: 28),

              // 신상품 섹션
              _SectionHeader(
                title: 'NEW ARRIVALS',
                onTap: () => context.go(AppRoutes.productList),
              ),
              const SizedBox(height: 12),
              _ProductGrid(products: newProducts),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 메인 배너 ──────────────────────────────
class _MainBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _MainBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.premiumPoint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.premiumPoint,
                      AppColors.primary.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('BEAUTY',
                    style: TextStyle(
                      fontFamily: 'Pretendard', fontSize: 28,
                      fontWeight: FontWeight.w800, color: AppColors.white,
                      letterSpacing: 2, height: 1.1,
                    ),
                  ),
                  const Text('BEYOND TIME',
                    style: TextStyle(
                      fontFamily: 'Pretendard', fontSize: 28,
                      fontWeight: FontWeight.w800, color: AppColors.white,
                      letterSpacing: 2, height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('SHOP NOW',
                      style: TextStyle(
                        fontFamily: 'Pretendard', fontSize: 12,
                        fontWeight: FontWeight.w600, color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 카테고리 섹션 ──────────────────────────
class _CategorySection extends StatelessWidget {
  final ValueChanged<ProductCategory> onSelect;
  const _CategorySection({required this.onSelect});

  static const _icons = {
    ProductCategory.medicalDevice: Icons.medical_services_outlined,
    ProductCategory.diagnostic:    Icons.biotech_outlined,
    ProductCategory.beautyCare:    Icons.spa_outlined,
    ProductCategory.medicine:      Icons.medication_outlined,
    ProductCategory.health:        Icons.health_and_safety_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: ProductCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final cat = ProductCategory.values[i];
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: Column(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Icon(_icons[cat], color: AppColors.primary, size: 24),
                ),
                const SizedBox(height: 6),
                Text(cat.label,
                  style: const TextStyle(
                    fontFamily: 'Pretendard', fontSize: 11,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── 섹션 헤더 ──────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _SectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style: const TextStyle(
              fontFamily: 'Pretendard', fontSize: 14,
              fontWeight: FontWeight.w700, color: AppColors.textMain,
              letterSpacing: 1.5,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Text('더보기 >',
              style: TextStyle(fontSize: 12, color: AppColors.textSub),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 상품 그리드 ─────────────────────────────
class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) => _ProductCard(product: products[i]),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(_iconForCategory(product.category),
                        size: 44, color: AppColors.premiumPoint),
                    ),
                  ),
                  if (product.tag != ProductTag.none)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
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
                    ),
                ],
              ),
            ),
            // 상품 정보
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                    style: const TextStyle(
                      fontFamily: 'Pretendard', fontSize: 12,
                      fontWeight: FontWeight.w500, color: AppColors.textMain,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(product.formattedPrice,
                    style: const TextStyle(
                      fontFamily: 'Pretendard', fontSize: 13,
                      fontWeight: FontWeight.w700, color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
