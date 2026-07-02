import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/state_views.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(wishlistProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('찜한 상품 (${products.length})')),
      body: products.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border,
              title: '찜한 상품이 없습니다',
              subtitle: '마음에 드는 상품을 하트로 담아보세요',
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
                  isFavorite: true, // 이 화면의 상품은 모두 찜한 상태
                  onFavoriteToggle: () =>
                      ref.read(wishlistProvider.notifier).toggle(product.id),
                  onTap: () => context.push('/products/${product.id}'),
                );
              },
            ),
    );
  }
}
