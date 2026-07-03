import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../data/models/product_model.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/state_views.dart';

enum SortType { recommend, popularity, priceAsc, priceDesc, newest }

class ProductListScreen extends ConsumerStatefulWidget {
  /// 진입 시 적용할 카테고리 (홈 화면에서 카테고리 클릭 시 전달됨)
  final ProductCategory? initialCategory;

  const ProductListScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  ProductCategory? _selectedCategory; // null = 전체
  SortType _sortType = SortType.recommend;
  bool _excludeSoldOut = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didUpdateWidget(covariant ProductListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 홈에서 다른 카테고리를 다시 선택했을 때도 반영
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() => _selectedCategory = widget.initialCategory);
    }
  }

  /// Repository에서 받아온 원본 목록에 정렬/품절제외 같은 "화면 전용" 처리를 적용합니다.
  /// (카테고리/키워드 필터링은 Repository 쪽 책임이라 여기서 다루지 않습니다.)
  List<Product> _applyLocalFilters(List<Product> source) {
    var list = source;

    if (_excludeSoldOut) {
      list = list.where((p) => !p.isSoldOut).toList();
    }

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
      case SortType.popularity:
        // 실 판매/조회 데이터가 없어 리뷰 수를 인기도 mock 기준으로 사용합니다.
        list = [...list]..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
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
              _sortOption('인기순', SortType.popularity),
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
    final favoriteIds = ref.watch(wishlistProvider);
    final query = ProductQuery(category: _selectedCategory);
    final productsAsync = ref.watch(productsProvider(query));

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
      body: Column(
        children: [
          // 카테고리 탭 (데이터 로딩 여부와 무관하게 항상 보이도록 바깥에 둡니다)
          _CategoryTabs(
            selected: _selectedCategory,
            onSelect: (cat) => setState(() => _selectedCategory = cat),
          ),
          const Divider(height: 1, color: AppColors.border),

          Expanded(
            child: productsAsync.when(
              data: (rawList) {
                final products = _applyLocalFilters(rawList);
                return Column(
                  children: [
                    // 필터/정렬 바
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('전체 ${products.length}개', style: AppTextStyles.body2),
                          Row(
                            children: [
                              _SoldOutToggleChip(
                                value: _excludeSoldOut,
                                onChanged: (v) => setState(() => _excludeSoldOut = v),
                              ),
                              const SizedBox(width: 12),
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
                        ],
                      ),
                    ),

                    // 상품 그리드
                    Expanded(
                      child: products.isEmpty
                          ? const Center(
                              child: Text('조건에 맞는 상품이 없습니다.', style: AppTextStyles.body2),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, i) {
                                final product = products[i];
                                return ProductCard(
                                  product: product,
                                  isFavorite: favoriteIds.contains(product.id),
                                  onFavoriteToggle: () =>
                                      ref.read(wishlistProvider.notifier).toggle(product.id),
                                  onTap: () => context.push('/products/${product.id}'),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const LoadingStateView(),
              error: (error, stack) => ErrorStateView(
                onRetry: () => ref.invalidate(productsProvider(query)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(SortType type) {
    switch (type) {
      case SortType.recommend:  return '추천순';
      case SortType.popularity: return '인기순';
      case SortType.newest:     return '신상품순';
      case SortType.priceAsc:   return '낮은 가격순';
      case SortType.priceDesc:  return '높은 가격순';
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

// ── 품절 제외 토글 칩 ─────────────────────
class _SoldOutToggleChip extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SoldOutToggleChip({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: value ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: value ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              size: 14,
              color: value ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(width: 4),
            Text('품절 제외',
              style: AppTextStyles.caption.copyWith(
                color: value ? AppColors.primary : AppColors.textSub,
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
