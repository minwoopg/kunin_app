/// 찜(관심상품) 데이터에 접근하는 방법을 추상화합니다.
/// 로그인 사용자 기준으로 서버에 저장하는 게 자연스러운 영역입니다.
abstract class FavoriteRepository {
  Future<Set<String>> getFavoriteIds();
  Future<Set<String>> toggle(String productId);
}

class MockFavoriteRepository implements FavoriteRepository {
  final Set<String> _ids = {};

  @override
  Future<Set<String>> getFavoriteIds() async => Set.unmodifiable(_ids);

  @override
  Future<Set<String>> toggle(String productId) async {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    return Set.unmodifiable(_ids);
  }
}
