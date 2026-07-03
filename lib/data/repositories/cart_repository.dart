import '../models/cart_model.dart';
import '../models/product_model.dart';

/// 장바구니 데이터에 접근하는 방법을 추상화합니다.
/// 실제 서버에서는 로그인 사용자 기준으로 저장되는 게 자연스러운 영역입니다.
abstract class CartRepository {
  Future<List<CartItem>> getCart();
  Future<List<CartItem>> addItem(Product product, {int quantity = 1});
  Future<List<CartItem>> increaseQuantity(String productId);
  Future<List<CartItem>> decreaseQuantity(String productId);
  Future<List<CartItem>> removeItem(String productId);
  Future<List<CartItem>> clear();
}

/// Mock 구현체. 실제 "서버"처럼 이 클래스 내부에서만 장바구니 데이터를 들고 있고,
/// Notifier는 이 결과를 그대로 반영만 합니다. (나중에 ApiCartRepository로 교체 시
/// 이 내부 로직이 실제 HTTP 호출로 바뀌는 것 외에는 아무것도 달라지지 않습니다.)
class MockCartRepository implements CartRepository {
  final List<CartItem> _items = [];

  @override
  Future<List<CartItem>> getCart() async => List.unmodifiable(_items);

  @override
  Future<List<CartItem>> addItem(Product product, {int quantity = 1}) async {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + quantity);
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> increaseQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> decreaseQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: _items[index].quantity - 1);
      }
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> removeItem(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    return List.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> clear() async {
    _items.clear();
    return List.unmodifiable(_items);
  }
}
