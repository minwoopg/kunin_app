import '../models/cart_model.dart';
import '../models/order_model.dart';

/// 주문 데이터에 접근하는 방법을 추상화합니다.
abstract class OrderRepository {
  Future<List<Order>> getOrders();

  /// 주문을 생성하고, 생성된 주문(서버가 채번한 주문번호 포함)을 반환합니다.
  Future<Order> createOrder({
    required List<CartItem> items,
    required int productPrice,
    required int shippingFee,
    required String receiverName,
    required String receiverPhone,
    required String address,
  });

  Future<List<Order>> cancelOrder(String orderId);
}

class MockOrderRepository implements OrderRepository {
  final List<Order> _orders = [];

  @override
  Future<List<Order>> getOrders() async => List.unmodifiable(_orders);

  @override
  Future<Order> createOrder({
    required List<CartItem> items,
    required int productPrice,
    required int shippingFee,
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) async {
    final order = Order(
      id: _generateOrderId(),
      items: items,
      productPrice: productPrice,
      shippingFee: shippingFee,
      totalPrice: productPrice + shippingFee,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      address: address,
      orderedAt: DateTime.now(),
    );
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<Order>> cancelOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
    }
    return List.unmodifiable(_orders);
  }

  String _generateOrderId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${_pad(now.month)}${_pad(now.day)}';
    final seq = (_orders.length + 1).toString().padLeft(4, '0');
    return 'ORD$dateStr$seq';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
