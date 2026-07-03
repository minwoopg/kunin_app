import '../models/address_model.dart';

/// 배송지 데이터에 접근하는 방법을 추상화합니다.
abstract class AddressRepository {
  Future<List<Address>> getAddresses();

  /// id 없이 필드만 전달하면 저장소가 새 id를 채번해서 붙입니다.
  /// (실제 서버라면 POST 응답으로 서버가 생성한 id를 돌려주는 것과 동일합니다.)
  Future<List<Address>> addAddress({
    required String label,
    required String receiverName,
    required String phone,
    required String address,
    String addressDetail = '',
    bool isDefault = false,
  });

  Future<List<Address>> updateAddress(Address address);
  Future<List<Address>> removeAddress(String id);
  Future<List<Address>> setDefaultAddress(String id);
}

class MockAddressRepository implements AddressRepository {
  final List<Address> _addresses = [_seed];

  static const _seed = Address(
    id: 'addr_default',
    label: '집',
    receiverName: '홍길동',
    phone: '010-1234-5678',
    address: '서울특별시 강남구 테헤란로 123 KIP빌딩 5층',
    isDefault: true,
  );

  @override
  Future<List<Address>> getAddresses() async => List.unmodifiable(_addresses);

  @override
  Future<List<Address>> addAddress({
    required String label,
    required String receiverName,
    required String phone,
    required String address,
    String addressDetail = '',
    bool isDefault = false,
  }) async {
    if (isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(Address(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      receiverName: receiverName,
      phone: phone,
      address: address,
      addressDetail: addressDetail,
      isDefault: isDefault,
    ));
    return List.unmodifiable(_addresses);
  }

  @override
  Future<List<Address>> updateAddress(Address updated) async {
    for (var i = 0; i < _addresses.length; i++) {
      if (_addresses[i].id == updated.id) {
        _addresses[i] = updated;
      } else if (updated.isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    return List.unmodifiable(_addresses);
  }

  @override
  Future<List<Address>> removeAddress(String id) async {
    final removingDefault = _addresses.any((a) => a.id == id && a.isDefault);
    _addresses.removeWhere((a) => a.id == id);

    // 기본 배송지를 삭제했다면 남은 것 중 첫 번째를 새 기본 배송지로 지정합니다.
    if (removingDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    return List.unmodifiable(_addresses);
  }

  @override
  Future<List<Address>> setDefaultAddress(String id) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
    return List.unmodifiable(_addresses);
  }
}
