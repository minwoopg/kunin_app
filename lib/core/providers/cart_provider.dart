import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/cart_repository.dart';

// cart_provider.dart 스스로도 CartItem을 사용해야 해서 import가 필요합니다.
// (export만 있으면 "이 파일을 import하는 다른 파일"에게는 CartItem이 넘어가지만
//  정작 이 파일 자신은 CartItem을 쓸 수 없습니다 - 이게 컴파일 에러의 원인이었습니다.)
export '../../data/models/cart_model.dart';

/// 장바구니 저장소 - 지금은 Mock 구현체를 사용합니다.
/// 나중에 실제 API로 바꿀 때는 이 한 줄만 교체하면 됩니다.
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return MockCartRepository();
});

/// 장바구니 상태관리
/// 실제 데이터는 Repository가 들고 있고, 여기서는 Repository 호출 결과를
/// Riverpod 상태로 그대로 반영하는 얇은 계층 역할만 합니다.
class CartNotifier extends StateNotifier<List<CartItem>> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super([]);

  /// 상품 추가 (이미 있으면 수량 증가)
  Future<void> addItem(Product product, {int quantity = 1}) async {
    state = await _repository.addItem(product, quantity: quantity);
  }

  /// 수량 증가
  Future<void> increaseQuantity(String productId) async {
    state = await _repository.increaseQuantity(productId);
  }

  /// 수량 감소 (1 미만이면 자동 제거)
  Future<void> decreaseQuantity(String productId) async {
    state = await _repository.decreaseQuantity(productId);
  }

  /// 상품 제거
  Future<void> removeItem(String productId) async {
    state = await _repository.removeItem(productId);
  }

  /// 전체 비우기
  Future<void> clear() async {
    state = await _repository.clear();
  }

  /// 총 상품 개수
  int get totalCount => state.fold(0, (sum, item) => sum + item.quantity);

  /// 총 금액
  int get totalPrice => state.fold(0, (sum, item) => sum + item.totalPrice);
}

/// 장바구니 Provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref.watch(cartRepositoryProvider));
});

/// 장바구니 총 개수 (뱃지용)
final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

/// 장바구니 총 금액
final cartTotalPriceProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.totalPrice);
});
