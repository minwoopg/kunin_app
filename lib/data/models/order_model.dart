import '../../core/providers/cart_provider.dart';

enum OrderStatus {
  pending('주문확인중'),
  preparing('상품준비중'),
  shipping('배송중'),
  delivered('배송완료'),
  cancelled('주문취소');

  final String label;
  const OrderStatus(this.label);
}

/// 주문 모델
class Order {
  final String id;
  final List<CartItem> items;
  final int productPrice;
  final int shippingFee;
  final int totalPrice;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final DateTime orderedAt;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.items,
    required this.productPrice,
    required this.shippingFee,
    required this.totalPrice,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.orderedAt,
    this.status = OrderStatus.pending,
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedTotalPrice {
    final str = totalPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '₩$buffer';
  }
}
