import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// 상품 저장소 - 지금은 Mock 구현체를 사용합니다.
/// 나중에 실제 API로 바꿀 때는 이 한 줄만 교체하면 됩니다.
///   return ApiProductRepository(dio);
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});

/// productsProvider에 여러 조건을 함께 넘기기 위한 값 객체.
/// category/keyword/tag 조합별로 결과가 각각 캐싱됩니다.
class ProductQuery {
  final ProductCategory? category;
  final String? keyword;
  final ProductTag? tag;

  const ProductQuery({this.category, this.keyword, this.tag});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductQuery &&
          other.category == category &&
          other.keyword == keyword &&
          other.tag == tag;

  @override
  int get hashCode => Object.hash(category, keyword, tag);
}

/// 상품 목록 조회 (조건별로 캐싱됨)
final productsProvider =
    FutureProvider.family<List<Product>, ProductQuery>((ref, query) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts(
    category: query.category,
    keyword: query.keyword,
    tag: query.tag,
  );
});

/// 상품 상세 조회 (id별로 캐싱됨)
final productDetailProvider =
    FutureProvider.family<Product?, String>((ref, id) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});
