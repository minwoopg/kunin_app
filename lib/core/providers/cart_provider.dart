import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

/// 장바구니 아이템
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  int get totalPrice => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// 장바구니 상태관리
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  /// 상품 추가 (이미 있으면 수량 증가)
  void addItem(Product product, {int quantity = 1}) {
    final index = state.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + quantity,
      );
      state = updated;
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  /// 수량 증가
  void increaseQuantity(String productId) {
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
  }

  /// 수량 감소 (1 미만이면 제거)
  void decreaseQuantity(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;

    if (state[index].quantity <= 1) {
      removeItem(productId);
    } else {
      state = state.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: item.quantity - 1);
        }
        return item;
      }).toList();
    }
  }

  /// 상품 제거
  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// 전체 비우기
  void clear() {
    state = [];
  }

  /// 총 상품 개수
  int get totalCount =>
      state.fold(0, (sum, item) => sum + item.quantity);

  /// 총 금액
  int get totalPrice =>
      state.fold(0, (sum, item) => sum + item.totalPrice);
}

/// 장바구니 Provider
final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
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
