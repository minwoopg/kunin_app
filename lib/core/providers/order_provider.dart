import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

/// 주문 저장소 - 지금은 Mock 구현체를 사용합니다.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return MockOrderRepository();
});

/// 주문 목록 상태관리
/// 실제 데이터는 Repository가 들고 있고, 여기서는 결과를 상태로 반영만 합니다.
class OrderNotifier extends StateNotifier<List<Order>> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super([]);

  /// 주문 생성 (최신 주문이 맨 앞에 오도록 추가)
  Future<Order> createOrder({
    required List<CartItem> items,
    required int productPrice,
    required int shippingFee,
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) async {
    final order = await _repository.createOrder(
      items: items,
      productPrice: productPrice,
      shippingFee: shippingFee,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      address: address,
    );
    state = [order, ...state];
    return order;
  }

  /// 주문 취소
  Future<void> cancelOrder(String orderId) async {
    state = await _repository.cancelOrder(orderId);
  }
}

/// 주문 목록 Provider
final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier(ref.watch(orderRepositoryProvider));
});

/// 가장 최근 주문 (주문완료 화면에서 사용)
final latestOrderProvider = Provider<Order?>((ref) {
  final orders = ref.watch(orderProvider);
  return orders.isEmpty ? null : orders.first;
});
