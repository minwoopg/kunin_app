import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/address_model.dart';

/// 배송지 관리 상태관리 (mock)
///
/// 실제 API 없이 메모리에서만 관리합니다. 기존에 주문서 작성 화면에 하드코딩되어
/// 있던 배송지 값을 기본 시드로 넣어두어, 기능 추가 전후로 첫 화면 동작이 동일합니다.
class AddressNotifier extends StateNotifier<List<Address>> {
  AddressNotifier() : super([_seed]);

  static const _seed = Address(
    id: 'addr_default',
    label: '집',
    receiverName: '홍길동',
    phone: '010-1234-5678',
    address: '서울특별시 강남구 테헤란로 123 KIP빌딩 5층',
    isDefault: true,
  );

  String generateId() => 'addr_${DateTime.now().millisecondsSinceEpoch}';

  void add(Address address) {
    final list = address.isDefault
        ? state.map((a) => a.copyWith(isDefault: false)).toList()
        : [...state];
    state = [...list, address];
  }

  void update(Address updated) {
    state = state.map((a) {
      if (a.id == updated.id) return updated;
      if (updated.isDefault) return a.copyWith(isDefault: false);
      return a;
    }).toList();
  }

  void remove(String id) {
    final removingDefault = state.any((a) => a.id == id && a.isDefault);
    final updated = state.where((a) => a.id != id).toList();

    // 기본 배송지를 삭제했다면 남은 것 중 첫 번째를 새 기본 배송지로 지정합니다.
    if (removingDefault && updated.isNotEmpty) {
      updated[0] = updated[0].copyWith(isDefault: true);
    }
    state = updated;
  }

  void setDefault(String id) {
    state = state.map((a) => a.copyWith(isDefault: a.id == id)).toList();
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
  return AddressNotifier();
});

/// 기본 배송지 (지정된 게 없으면 첫 번째, 목록이 비었으면 null)
final defaultAddressProvider = Provider<Address?>((ref) {
  final list = ref.watch(addressProvider);
  if (list.isEmpty) return null;
  return list.firstWhere((a) => a.isDefault, orElse: () => list.first);
});
