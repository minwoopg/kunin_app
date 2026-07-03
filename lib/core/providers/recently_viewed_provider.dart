import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/recently_viewed_repository.dart';

/// 최근 본 상품 저장소 - SharedPreferences 기반 로컬 구현체를 사용합니다.
/// (다른 도메인과 달리 이 영역은 나중에도 서버 API로 바꿀 계획이 없습니다.)
final recentlyViewedRepositoryProvider = Provider<RecentlyViewedRepository>((ref) {
  return LocalRecentlyViewedRepository();
});

/// 최근 본 상품 상태관리
/// 실제 데이터는 Repository(SharedPreferences)가 들고 있고, 여기서는
/// 앱 시작 시 한 번 불러온 뒤 Repository 호출 결과를 상태로 반영만 합니다.
class RecentlyViewedNotifier extends StateNotifier<List<String>> {
  final RecentlyViewedRepository _repository;

  RecentlyViewedNotifier(this._repository) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repository.getRecentlyViewedIds();
  }

  Future<void> addProduct(String productId) async {
    state = await _repository.addProduct(productId);
  }

  Future<void> remove(String productId) async {
    state = await _repository.remove(productId);
  }

  Future<void> clear() async {
    state = await _repository.clear();
  }
}

/// 최근 본 상품 ID 목록 (최신순)
final recentlyViewedProvider = StateNotifierProvider<RecentlyViewedNotifier, List<String>>((ref) {
  return RecentlyViewedNotifier(ref.watch(recentlyViewedRepositoryProvider));
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
