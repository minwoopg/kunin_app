/// 배송지 모델 (mock)
class Address {
  final String id;
  final String label;         // "집", "회사" 같은 배송지 별칭
  final String receiverName;
  final String phone;
  final String address;
  final String addressDetail; // 상세주소 (동/호수 등), 없으면 빈 문자열
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.receiverName,
    required this.phone,
    required this.address,
    this.addressDetail = '',
    this.isDefault = false,
  });

  /// 주소 + 상세주소를 합친 표시/주문용 문자열
  String get fullAddress =>
      addressDetail.isEmpty ? address : '$address $addressDetail';

  Address copyWith({
    String? label,
    String? receiverName,
    String? phone,
    String? address,
    String? addressDetail,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      label: label ?? this.label,
      receiverName: receiverName ?? this.receiverName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      addressDetail: addressDetail ?? this.addressDetail,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
