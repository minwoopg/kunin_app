import 'package:shared_preferences/shared_preferences.dart';

/// 최근 본 상품 데이터에 접근하는 방법을 추상화합니다.
///
/// 다른 도메인(Product/Cart/Order/Favorite/Address)과 다르게, 이 영역은
/// 서버 API로 갈 계획이 없습니다. "이 기기에서 무엇을 봤는지"는 로그인 여부와
/// 무관하게 기기 로컬에 남는 게 자연스러운 데이터라서, 구현체 이름도
/// Mock이 아니라 Local로 지어서 "이게 최종 구현"이라는 걸 명확히 했습니다.
abstract class RecentlyViewedRepository {
  Future<List<String>> getRecentlyViewedIds();
  Future<List<String>> addProduct(String productId);
  Future<List<String>> remove(String productId);
  Future<List<String>> clear();
}

/// SharedPreferences 기반 구현체.
/// 상품 ID를 최근 조회 순서(문자열 리스트)로 저장합니다.
/// 같은 상품을 다시 보면 기존 위치에서 제거하고 맨 앞으로 다시 추가해서
/// 중복 없이 최신순을 유지하고, 최대 20개까지만 보관합니다.
class LocalRecentlyViewedRepository implements RecentlyViewedRepository {
  static const _key = 'recently_viewed_product_ids';
  static const _maxItems = 20;

  @override
  Future<List<String>> getRecentlyViewedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  @override
  Future<List<String>> addProduct(String productId) async {
    final current = await getRecentlyViewedIds();
    final updated = [productId, ...current.where((id) => id != productId)];
    final trimmed = updated.length > _maxItems ? updated.sublist(0, _maxItems) : updated;
    await _save(trimmed);
    return trimmed;
  }

  @override
  Future<List<String>> remove(String productId) async {
    final current = await getRecentlyViewedIds();
    final updated = current.where((id) => id != productId).toList();
    await _save(updated);
    return updated;
  }

  @override
  Future<List<String>> clear() async {
    await _save([]);
    return [];
  }

  Future<void> _save(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }
}
