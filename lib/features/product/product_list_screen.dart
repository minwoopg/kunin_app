import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/cart_provider.dart';
import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';
import '../../shared/theme/app_theme.dart';

enum SortType { recommend, priceAsc, priceDesc, newest }

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  ProductCategory? _selectedCategory; // null = 전체
  SortType _sortType = SortType.recommend;

  List<Product> get _products {
    var list = MockProducts.byCategory(_selectedCategory);

    switch (_sortType) {
      case SortType.priceAsc:
        list = [...list]..sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.priceDesc:
        list = [...list]..sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.newest:
        list = [...list]..sort((a, b) {
          if (a.tag == ProductTag.newItem && b.tag != ProductTag.newItem) return -1;
          if (a.tag != ProductTag.newItem && b.tag == ProductTag.newItem) return 1;
          return 0;
        });
        break;
      case SortType.recommend:
        break;
    }
    return list;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              _sortOption('추천순', SortType.recommend),
              _sortOption('신상품순', SortType.newest),
              _sortOption('낮은 가격순', SortType.priceAsc),
              _sortOption('높은 가격순', SortType.priceDesc),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _sortOption(String label, SortType type) {
    final selected = _sortType == type;
    return ListTile(
      title: Text(label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? AppColors.primary : AppColors.textMain,
        ),
      ),
      trailing: selected ? const Icon(Icons.check, color: AppColors.primary, size: 18) : null,
      onTap: () {
        setState(() => _sortType = type);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('KIP 2026',
          style: TextStyle(
            fontFamily: 'Pretendard', fontSize: 18,
            fontWeight: FontWeight.w700, color: AppColors.textMain,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textMain),
            onPressed: () {},
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
        ],
      ),
      body: Column(
        children: [
          // 카테고리 탭
          _CategoryTabs(
            selected: _selectedCategory,
            onSelect: (cat) => setState(() => _selectedCategory = cat),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 필터/정렬 바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('전체 ${_products.length}개',
                  style: AppTextStyles.body2,
                ),
                GestureDetector(
                  onTap: _showSortSheet,
                  child: Row(
                    children: [
                      Text(_sortLabel(_sortType), style: AppTextStyles.body2),
                      const SizedBox(width: 4),
                      const Icon(Icons.unfold_more, size: 16, color: AppColors.textSub),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 상품 그리드
          Expanded(
            child: _products.isEmpty
                ? const Center(
                    child: Text('해당 카테고리에 상품이 없습니다.', style: AppTextStyles.body2),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, i) {
                      final product = _products[i];
                      return _ProductCard(
                        product: product,
                        onTap: () => context.push('/products/${product.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(SortType type) {
    switch (type) {
      case SortType.recommend: return '추천순';
      case SortType.newest:    return '신상품순';
      case SortType.priceAsc:  return '낮은 가격순';
      case SortType.priceDesc: return '높은 가격순';
    }
  }
}

// ── 카테고리 탭 ──────────────────────────
class _CategoryTabs extends StatelessWidget {
  final ProductCategory? selected;
  final ValueChanged<ProductCategory?> onSelect;

  const _CategoryTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _chip('전체', null),
          for (final cat in ProductCategory.values) _chip(cat.label, cat),
        ],
      ),
    );
  }

  Widget _chip(String label, ProductCategory? value) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppColors.white : AppColors.textSub,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 상품 카드 ──────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                      child: Icon(
                        _iconForCategory(product.category),
                        size: 44,
                        color: AppColors.premiumPoint,
                      ),
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
                  if (product.isSoldOut)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Center(
                          child: Text('SOLD OUT',
                            style: TextStyle(
                              color: AppColors.white, fontWeight: FontWeight.w700,
                              fontSize: 13, letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 정보 영역
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
                  if (product.reviewCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 11, color: AppColors.premiumPoint),
                        const SizedBox(width: 2),
                        Text('${product.rating}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSub),
                        ),
                        const SizedBox(width: 4),
                        Text('(${product.reviewCount})',
                          style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ],
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
