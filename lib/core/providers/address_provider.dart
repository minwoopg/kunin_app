import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';

/// 배송지 저장소 - 지금은 Mock 구현체를 사용합니다.
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return MockAddressRepository();
});

/// 배송지 상태관리
///
/// 다른 도메인(장바구니/주문/찜)과 달리 이 Notifier만 예외적으로
/// **초기 상태를 동기적으로 시드**합니다. 주문서 작성 화면이 initState에서
/// "기본 배송지"를 즉시 읽어와 입력창을 채우는데, 만약 초기 상태를 Repository에서
/// 비동기로 가져오게 하면 그 사이의 짧은 순간에 배송지가 비어있는 것으로 보일 수
/// 있기 때문입니다. 추가/수정/삭제/기본설정 같은 이후의 모든 변경은 그대로
/// Repository를 거칩니다.
class AddressNotifier extends StateNotifier<List<Address>> {
  final AddressRepository _repository;

  AddressNotifier(this._repository) : super(const [_seed]);

  static const _seed = Address(
    id: 'addr_default',
    label: '집',
    receiverName: '홍길동',
    phone: '010-1234-5678',
    address: '서울특별시 강남구 테헤란로 123 KIP빌딩 5층',
    isDefault: true,
  );

  Future<void> add({
    required String label,
    required String receiverName,
    required String phone,
    required String address,
    String addressDetail = '',
    bool isDefault = false,
  }) async {
    state = await _repository.addAddress(
      label: label,
      receiverName: receiverName,
      phone: phone,
      address: address,
      addressDetail: addressDetail,
      isDefault: isDefault,
    );
  }

  Future<void> update(Address updated) async {
    state = await _repository.updateAddress(updated);
  }

  Future<void> remove(String id) async {
    state = await _repository.removeAddress(id);
  }

  Future<void> setDefault(String id) async {
    state = await _repository.setDefaultAddress(id);
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
  return AddressNotifier(ref.watch(addressRepositoryProvider));
});

/// 기본 배송지 (지정된 게 없으면 첫 번째, 목록이 비었으면 null)
final defaultAddressProvider = Provider<Address?>((ref) {
  final list = ref.watch(addressProvider);
  if (list.isEmpty) return null;
  return list.firstWhere((a) => a.isDefault, orElse: () => list.first);
});
