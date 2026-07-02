import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';

/// 찜(관심상품) 상태관리
///
/// 상품 ID의 Set으로 보관합니다. Dart의 Set 리터럴은 내부적으로 LinkedHashSet이라
/// 추가한 순서를 그대로 유지하므로, 별도 정렬 로직 없이도 "찜한 순서"를 알 수 있습니다.
///
/// 지금은 메모리에만 저장되어 앱을 재시작하면 초기화됩니다.
/// (백엔드 연동 이후에는 서버에 찜 목록을 저장하도록 이 부분만 교체할 예정입니다.)
class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super({});

  void toggle(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  bool isFavorite(String productId) => state.contains(productId);
}

/// 찜한 상품 ID 목록 (Set)
final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier();
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
