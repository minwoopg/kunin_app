/// 상품 카테고리
enum ProductCategory {
  medicalDevice('의료기기'),
  diagnostic('진단장비'),
  beautyCare('뷰티케어'),
  medicine('의약품'),
  health('건강식품');

  final String label;
  const ProductCategory(this.label);
}

/// 상품 태그
enum ProductTag {
  none(''),
  newItem('NEW'),
  best('BEST');

  final String label;
  const ProductTag(this.label);
}

/// 상품 모델
class Product {
  final String id;
  final String name;
  final ProductCategory category;
  final int price;
  final String description;
  final String detailDescription;
  final int stock;
  final String? imageUrl;
  final ProductTag tag;
  final double rating;
  final int reviewCount;
  final String manufacturer;
  final String origin;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.detailDescription = '',
    required this.stock,
    this.imageUrl,
    this.tag = ProductTag.none,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.manufacturer = '',
    this.origin = '대한민국',
  });

  /// 1,000 단위 콤마 가격 문자열 (₩9,800,000)
  String get formattedPrice {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '₩$buffer';
  }

  bool get isSoldOut => stock <= 0;
}
