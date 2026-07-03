import 'product_model.dart';

/// 장바구니 아이템.
/// 원래 core/providers/cart_provider.dart 안에 있었는데,
/// Repository 계층이 Provider 파일을 참조하는 역방향 의존을 피하기 위해
/// data/models로 옮겼습니다. (cart_provider.dart에서 그대로 재수출하므로
/// 기존에 CartItem을 쓰던 화면들의 import는 수정할 필요가 없습니다.)
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
