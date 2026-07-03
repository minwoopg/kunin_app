import '../mock/mock_products.dart';
import '../models/product_model.dart';

/// 상품 데이터에 접근하는 방법을 추상화합니다.
///
/// 지금은 [MockProductRepository]만 있지만, 나중에 실제 백엔드가 준비되면
/// 이 인터페이스를 구현하는 ApiProductRepository로 교체하기만 하면 됩니다.
/// (화면/Provider 코드는 건드릴 필요가 없습니다.)
abstract class ProductRepository {
  /// 상품 목록 조회. 파라미터를 조합해서 필터링합니다.
  /// (실제 API에서는 이 파라미터들이 그대로 쿼리 파라미터가 될 예정입니다.)
  Future<List<Product>> getProducts({
    ProductCategory? category,
    String? keyword,
    ProductTag? tag,
  });

  /// 상품 상세 조회. 없으면 null.
  Future<Product?> getProductById(String id);
}

/// Mock 데이터 기반 구현체.
/// 실제로는 동기 연산이지만, 나중에 API로 교체했을 때 화면 코드가
/// 그대로 재사용되도록 반환 타입을 처음부터 Future로 맞춰둡니다.
class MockProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts({
    ProductCategory? category,
    String? keyword,
    ProductTag? tag,
  }) async {
    var list = MockProducts.byCategory(category);

    if (tag != null) {
      list = list.where((p) => p.tag == tag).toList();
    }

    if (keyword != null && keyword.trim().isNotEmpty) {
      final lower = keyword.trim().toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(lower) ||
              p.description.toLowerCase().contains(lower))
          .toList();
    }

    return list;
  }

  @override
  Future<Product?> getProductById(String id) async {
    return MockProducts.findById(id);
  }
}
