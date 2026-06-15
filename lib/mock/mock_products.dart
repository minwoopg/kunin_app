import '../models/product_model.dart';

/// 백엔드 연동 전 임시 상품 데이터
class MockProducts {
  MockProducts._();

  static final List<Product> all = [
    // ── 의료기기 ──────────────────────────
    const Product(
      id: 'p001',
      name: '초음파 진단기기 KIP-U100',
      category: ProductCategory.medicalDevice,
      price: 9800000,
      description: '프리미엄 휴대용 초음파 진단기기',
      detailDescription:
          '최신 영상처리 기술을 적용한 휴대용 초음파 진단기기입니다.\n'
          '고해상도 화질과 직관적인 UI로 빠르고 정확한 진단이 가능합니다.\n\n'
          '· 무선 프로브 지원\n'
          '· 배터리 연속 사용 4시간\n'
          '· DICOM 표준 지원',
      stock: 5,
      tag: ProductTag.newItem,
      rating: 4.8,
      reviewCount: 12,
      manufacturer: 'KIP MEDICAL',
    ),
    const Product(
      id: 'p002',
      name: '환자 모니터 KIP-M200',
      category: ProductCategory.medicalDevice,
      price: 1250000,
      description: '다기능 환자 생체신호 모니터',
      detailDescription:
          '심전도, 혈압, 산소포화도를 동시에 모니터링할 수 있는 환자 모니터입니다.\n\n'
          '· 12.1인치 풀컬러 터치스크린\n'
          '· NIBP / SpO2 / ECG / RESP 동시 측정\n'
          '· 알람 기능 내장',
      stock: 8,
      tag: ProductTag.best,
      rating: 4.6,
      reviewCount: 28,
      manufacturer: 'KIP MEDICAL',
    ),
    const Product(
      id: 'p003',
      name: '전동 휠체어 KIP-WC500',
      category: ProductCategory.medicalDevice,
      price: 2150000,
      description: '경량 알루미늄 프레임 전동 휠체어',
      detailDescription:
          '가볍고 견고한 알루미늄 프레임으로 제작된 전동 휠체어입니다.\n\n'
          '· 1회 충전 주행거리 약 25km\n'
          '· 최대 속도 6km/h\n'
          '· 접이식 디자인',
      stock: 3,
      rating: 4.5,
      reviewCount: 9,
      manufacturer: 'KIP MOBILITY',
    ),

    // ── 진단장비 ──────────────────────────
    const Product(
      id: 'p004',
      name: '산소포화도 측정기 KIP-OX1',
      category: ProductCategory.diagnostic,
      price: 180000,
      description: '휴대용 펄스옥시미터',
      detailDescription:
          '손가락에 끼우는 것만으로 산소포화도와 맥박을 측정할 수 있습니다.\n\n'
          '· 1초 빠른 측정\n'
          '· OLED 디스플레이\n'
          '· 자동 전원 차단 기능',
      stock: 42,
      tag: ProductTag.newItem,
      rating: 4.7,
      reviewCount: 56,
      manufacturer: 'KIP MEDICAL',
    ),
    const Product(
      id: 'p005',
      name: '디지털 혈압계 KIP-BP300',
      category: ProductCategory.diagnostic,
      price: 89000,
      description: '가정용 자동 혈압측정기',
      detailDescription:
          '간편한 원터치 조작으로 정확한 혈압을 측정할 수 있는 가정용 혈압계입니다.\n\n'
          '· 부정맥 감지 기능\n'
          '· 최대 90회 측정값 저장\n'
          '· 대형 LCD 디스플레이',
      stock: 67,
      rating: 4.4,
      reviewCount: 103,
      manufacturer: 'KIP MEDICAL',
    ),
    const Product(
      id: 'p006',
      name: '비접촉 체온계 KIP-TM150',
      category: ProductCategory.diagnostic,
      price: 45000,
      description: '1초 비접촉 적외선 체온계',
      detailDescription:
          '이마에 가까이 대기만 하면 1초 안에 체온을 측정합니다.\n\n'
          '· 비접촉식 측정\n'
          '· 발열 알람 기능\n'
          '· 32회 측정 기록 저장',
      stock: 120,
      tag: ProductTag.best,
      rating: 4.5,
      reviewCount: 210,
      manufacturer: 'KIP MEDICAL',
    ),

    // ── 뷰티케어 ──────────────────────────
    const Product(
      id: 'p007',
      name: '홈케어 뷰티 디바이스 KIP-2026',
      category: ProductCategory.beautyCare,
      price: 398000,
      description: '프리미엄 LED 홈케어 뷰티 디바이스',
      detailDescription:
          'LED 광선 테라피와 고주파 마사지를 결합한 프리미엄 홈케어 디바이스입니다.\n\n'
          '· 3가지 LED 모드 (레드/블루/그린)\n'
          '· EMS 마이크로커런트\n'
          '· 1회 충전 약 90분 사용',
      stock: 15,
      tag: ProductTag.newItem,
      rating: 4.9,
      reviewCount: 87,
      manufacturer: 'KIP BEAUTY',
    ),
    const Product(
      id: 'p008',
      name: '이온 클렌징 디바이스 KIP-C50',
      category: ProductCategory.beautyCare,
      price: 129000,
      description: '실리콘 음이온 클렌징 브러시',
      detailDescription:
          '초음파 진동과 음이온 기술로 모공 속 노폐물을 깨끗하게 제거합니다.\n\n'
          '· IPX7 방수\n'
          '· 3단계 강도 조절\n'
          '· USB-C 충전',
      stock: 34,
      rating: 4.6,
      reviewCount: 64,
      manufacturer: 'KIP BEAUTY',
    ),
    const Product(
      id: 'p009',
      name: '두피 마사지기 KIP-SC10',
      category: ProductCategory.beautyCare,
      price: 79000,
      description: '전동 두피 마사지 디바이스',
      detailDescription:
          '4개의 실리콘 헤드가 두피를 자극하여 혈액순환을 돕습니다.\n\n'
          '· 방수 설계\n'
          '· 무선 충전식\n'
          '· 저소음 모터',
      stock: 50,
      rating: 4.3,
      reviewCount: 41,
      manufacturer: 'KIP BEAUTY',
    ),

    // ── 의약품 ──────────────────────────────
    const Product(
      id: 'p010',
      name: '의료용 소독제 KIP-GEL250',
      category: ProductCategory.medicine,
      price: 28000,
      description: '손소독 겔 250ml',
      detailDescription:
          '에탄올 함유 손소독제로 99.9% 살균 효과가 있습니다.\n\n'
          '· 250ml 휴대용 용량\n'
          '· 보습 성분 함유\n'
          '· 식약처 인증',
      stock: 200,
      rating: 4.2,
      reviewCount: 156,
      manufacturer: 'KIP PHARMA',
    ),
    const Product(
      id: 'p011',
      name: '상처 드레싱 밴드 KIP-WD30',
      category: ProductCategory.medicine,
      price: 15000,
      description: '방수 상처 드레싱 밴드 30매',
      detailDescription:
          '습윤 환경을 유지하여 흉터를 최소화하는 상처 드레싱 밴드입니다.\n\n'
          '· 30매입\n'
          '· 방수 / 투명 재질\n'
          '· 다양한 사이즈 구성',
      stock: 89,
      rating: 4.1,
      reviewCount: 23,
      manufacturer: 'KIP PHARMA',
    ),

    // ── 건강기능식품 ──────────────────────
    const Product(
      id: 'p012',
      name: '프로바이오틱스 KIP-BIO100',
      category: ProductCategory.health,
      price: 42000,
      description: '장 건강 유산균 100억 CFU',
      detailDescription:
          '1박스 30포, 1일 1포로 장 건강과 면역력 관리에 도움을 줍니다.\n\n'
          '· 100억 CFU 고함량\n'
          '· 코팅 공법으로 위산에서 보호\n'
          '· 1박스 30포 (1개월분)',
      stock: 75,
      tag: ProductTag.best,
      rating: 4.7,
      reviewCount: 198,
      manufacturer: 'KIP HEALTH',
    ),
    const Product(
      id: 'p013',
      name: '오메가3 KIP-OM90',
      category: ProductCategory.health,
      price: 35000,
      description: '고함량 정제 오메가3 90캡슐',
      detailDescription:
          '혈중 중성지질 개선에 도움을 줄 수 있는 정제어유 함유 제품입니다.\n\n'
          '· EPA+DHA 1,000mg\n'
          '· 90캡슐 (3개월분)\n'
          '· 비린맛 저감 공법',
      stock: 60,
      rating: 4.4,
      reviewCount: 77,
      manufacturer: 'KIP HEALTH',
    ),
    const Product(
      id: 'p014',
      name: '비타민D KIP-VD60',
      category: ProductCategory.health,
      price: 19800,
      description: '고함량 비타민D3 60캡슐',
      detailDescription:
          '뼈와 면역 건강에 필요한 비타민D를 보충할 수 있는 제품입니다.\n\n'
          '· 1캡슐당 비타민D3 1000IU\n'
          '· 60캡슐 (2개월분)\n'
          '· 소형 캡슐로 섭취 편리',
      stock: 0, // 품절 테스트
      rating: 4.3,
      reviewCount: 34,
      manufacturer: 'KIP HEALTH',
    ),
  ];

  /// 카테고리별 상품 조회
  static List<Product> byCategory(ProductCategory? category) {
    if (category == null) return all;
    return all.where((p) => p.category == category).toList();
  }

  /// ID로 상품 조회
  static Product? findById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 키워드 검색
  static List<Product> search(String keyword) {
    final lower = keyword.toLowerCase();
    return all.where((p) =>
      p.name.toLowerCase().contains(lower) ||
      p.description.toLowerCase().contains(lower)
    ).toList();
  }
}
