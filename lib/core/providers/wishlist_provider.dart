import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/favorite_repository.dart';

/// 찜 저장소 - 지금은 Mock 구현체를 사용합니다.
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return MockFavoriteRepository();
});

/// 찜(관심상품) 상태관리
/// 실제 데이터는 Repository가 들고 있고, 여기서는 결과를 상태로 반영만 합니다.
class WishlistNotifier extends StateNotifier<Set<String>> {
  final FavoriteRepository _repository;

  WishlistNotifier(this._repository) : super({});

  Future<void> toggle(String productId) async {
    state = await _repository.toggle(productId);
  }

  bool isFavorite(String productId) => state.contains(productId);
}

/// 찜한 상품 ID 목록 (Set)
final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier(ref.watch(favoriteRepositoryProvider));
});

/// 찜한 상품 개수 (마이페이지 뱃지 등에서 사용)
final wishlistCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistProvider).length;
});

/// 찜한 상품 목록 (Product 객체로 변환, 최근 찜한 순)
final wishlistProductsProvider = Provider<List<Product>>((ref) {
  final ids = ref.watch(wishlistProvider);
  return ids
      .map((id) => MockProducts.findById(id))
      .whereType<Product>()
      .toList()
      .reversed
      .toList();
});
