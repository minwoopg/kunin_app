import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../theme/app_theme.dart';

/// KIP 공통 상품 카드
///
/// 기존에 home_screen / product_list_screen / search_screen
/// 세 화면에 거의 동일한 코드로 중복되어 있던 상품 카드를 하나로 통합했습니다.
/// 이제 상품 카드 디자인을 바꿀 일이 있으면 이 파일 하나만 수정하면 됩니다.
///
/// [isFavorite] / [onFavoriteToggle] 은 찜 기능(다음 단계)을 위해 미리 열어둔
/// 옵션 파라미터입니다. onFavoriteToggle을 넘기지 않으면 하트 아이콘 자체가
/// 표시되지 않으므로, 지금 이 카드를 쓰는 화면들의 동작은 기존과 동일합니다.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.background,
                    child: Center(
                      child: Icon(
                        _iconForCategory(product.category),
                        size: 42,
                        color: AppColors.premiumPoint,
                      ),
                    ),
                  ),
                  if (product.tag != ProductTag.none)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _TagBadge(tag: product.tag),
                    ),
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _FavoriteButton(
                        isFavorite: isFavorite,
                        onTap: onFavoriteToggle!,
                      ),
                    ),
                  if (product.isSoldOut)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        alignment: Alignment.center,
                        child: const Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 정보 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.body1.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(product.formattedPrice, style: AppTextStyles.price),
                  if (product.reviewCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: AppColors.premiumPoint),
                        const SizedBox(width: 3),
                        Text(
                          '${product.rating}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSub,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('(${product.reviewCount})', style: AppTextStyles.caption),
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
      case ProductCategory.medicalDevice:
        return Icons.medical_services_outlined;
      case ProductCategory.diagnostic:
        return Icons.biotech_outlined;
      case ProductCategory.beautyCare:
        return Icons.spa_outlined;
      case ProductCategory.medicine:
        return Icons.medication_outlined;
      case ProductCategory.health:
        return Icons.health_and_safety_outlined;
    }
  }
}

class _TagBadge extends StatelessWidget {
  final ProductTag tag;
  const _TagBadge({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tag == ProductTag.best ? AppColors.primary : AppColors.textMain,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        tag.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 15,
          color: isFavorite ? AppColors.error : AppColors.textSub,
        ),
      ),
    );
  }
}
