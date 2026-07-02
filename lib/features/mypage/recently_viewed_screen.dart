import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/recently_viewed_provider.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/state_views.dart';

class RecentlyViewedScreen extends ConsumerWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(recentlyViewedProductsProvider);
    final favoriteIds = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('최근 본 상품 (${products.length})'),
        actions: [
          if (products.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, ref),
              child: const Text('전체삭제',
                style: TextStyle(fontSize: 13, color: AppColors.textSub),
              ),
            ),
        ],
      ),
      body: products.isEmpty
          ? EmptyStateView(
              icon: Icons.history,
              title: '최근 본 상품이 없습니다',
              subtitle: '상품을 둘러보면 여기에 기록됩니다',
              buttonLabel: '쇼핑 계속하기',
              onButtonTap: () => context.go(AppRoutes.productList),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('최근 본 상품 삭제', style: AppTextStyles.h3),
        content: const Text('최근 본 상품 기록을 모두 삭제하시겠습니까?', style: AppTextStyles.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              ref.read(recentlyViewedProvider.notifier).clear();
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
