import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';

/// 최근 본 상품 상태관리
///
/// 상품 ID를 "최근 조회 순서"대로 List에 보관합니다.
/// 같은 상품을 다시 보면 기존 위치에서 제거하고 맨 앞으로 다시 추가해서
/// 중복 없이 최신순을 유지합니다. 최대 20개까지만 보관합니다.
///
/// 지금은 메모리에만 저장되어 앱을 재시작하면 초기화됩니다.
class RecentlyViewedNotifier extends StateNotifier<List<String>> {
  RecentlyViewedNotifier() : super([]);

  static const int _maxItems = 20;

  void addProduct(String productId) {
    final updated = [productId, ...state.where((id) => id != productId)];
    state = updated.length > _maxItems ? updated.sublist(0, _maxItems) : updated;
  }

  void remove(String productId) {
    state = state.where((id) => id != productId).toList();
  }

  void clear() {
    state = [];
  }
}

/// 최근 본 상품 ID 목록 (최신순)
final recentlyViewedProvider = StateNotifierProvider<RecentlyViewedNotifier, List<String>>((ref) {
  return RecentlyViewedNotifier();
});

/// 최근 본 상품 개수
final recentlyViewedCountProvider = Provider<int>((ref) {
  return ref.watch(recentlyViewedProvider).length;
});

/// 최근 본 상품 목록 (Product 객체로 변환, 최신순)
final recentlyViewedProductsProvider = Provider<List<Product>>((ref) {
  final ids = ref.watch(recentlyViewedProvider);
  return ids.map((id) => MockProducts.findById(id)).whereType<Product>().toList();
});
