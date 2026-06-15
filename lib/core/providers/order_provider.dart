import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import 'cart_provider.dart';

/// 주문 목록 상태관리 (Mock - 메모리 저장)
class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier() : super([]);

  /// 주문 생성 (최신 주문이 맨 앞에 오도록 추가)
  Order createOrder({
    required List<CartItem> items,
    required int productPrice,
    required int shippingFee,
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) {
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

    state = [order, ...state];
    return order;
  }

  /// 주문 취소
  void cancelOrder(String orderId) {
    state = state.map((order) {
      if (order.id == orderId) {
        return Order(
          id: order.id,
          items: order.items,
          productPrice: order.productPrice,
          shippingFee: order.shippingFee,
          totalPrice: order.totalPrice,
          receiverName: order.receiverName,
          receiverPhone: order.receiverPhone,
          address: order.address,
          orderedAt: order.orderedAt,
          status: OrderStatus.cancelled,
        );
      }
      return order;
    }).toList();
  }

  String _generateOrderId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${_pad(now.month)}${_pad(now.day)}';
    final seq = (state.length + 1).toString().padLeft(4, '0');
    return 'ORD$dateStr$seq';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

/// 주문 목록 Provider
final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier();
});

/// 가장 최근 주문 (주문완료 화면에서 사용)
final latestOrderProvider = Provider<Order?>((ref) {
  final orders = ref.watch(orderProvider);
  return orders.isEmpty ? null : orders.first;
});
