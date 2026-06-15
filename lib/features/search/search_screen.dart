import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/cart_provider.dart';
import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';
import '../../shared/theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String _query = '';
  List<Product> _results = [];

  // 임시 인기 검색어
  static const _popularKeywords = [
    '초음파 진단기기', '뷰티 디바이스', '혈압계', '오메가3', '체온계', '프로바이오틱스', '휠체어',
  ];

  // 최근 검색어 (메모리 저장)
  final List<String> _recentKeywords = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _query = trimmed;
      _controller.text = trimmed;
      _results = MockProducts.search(trimmed);

      _recentKeywords.remove(trimmed);
      _recentKeywords.insert(0, trimmed);
      if (_recentKeywords.length > 8) _recentKeywords.removeLast();
    });
    _focusNode.unfocus();
  }

  void _clear() {
    setState(() {
      _query = '';
      _controller.clear();
      _results = [];
    });
    _focusNode.requestFocus();
  }

  void _removeRecent(String keyword) {
    setState(() => _recentKeywords.remove(keyword));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search, size: 18, color: AppColors.textSub),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textMain),
                  decoration: const InputDecoration(
                    hintText: '상품명을 검색해보세요',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  onSubmitted: _onSearch,
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: _clear,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.close, size: 16, color: AppColors.textHint),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _query.isEmpty ? _buildSuggestions() : _buildResults(),
    );
  }

  // ── 검색 전: 인기/최근 검색어 ───────────────
  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentKeywords.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('최근 검색어', style: AppTextStyles.h3),
                GestureDetector(
                  onTap: () => setState(() => _recentKeywords.clear()),
                  child: Text('전체삭제', style: AppTextStyles.body2.copyWith(color: AppColors.textSub)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _recentKeywords.map((k) => _RecentChip(
                label: k,
                onTap: () => _onSearch(k),
                onRemove: () => _removeRecent(k),
              )).toList(),
            ),
            const SizedBox(height: 28),
          ],

          const Text('인기 검색어', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ...List.generate(_popularKeywords.length, (i) {
            final keyword = _popularKeywords[i];
            return InkWell(
              onTap: () => _onSearch(keyword),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${i + 1}',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: i < 3 ? AppColors.primary : AppColors.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(keyword, style: AppTextStyles.body1),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── 검색 결과 ──────────────────────────────
  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text("'$_query'에 대한 검색결과가 없습니다.", style: AppTextStyles.body2),
            const SizedBox(height: 6),
            const Text('다른 검색어로 시도해보세요.', style: AppTextStyles.caption),
          ],
        ),
      );
    }

    final cartCount = ref.watch(cartCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Text("'$_query' 검색결과 ", style: AppTextStyles.body2),
              Text('${_results.length}개', style: AppTextStyles.body2.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w700,
              )),
              const Spacer(),
              if (cartCount > 0)
                Text('장바구니 $cartCount', style: AppTextStyles.caption),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: _results.length,
            itemBuilder: (context, i) {
              final product = _results[i];
              return _SearchResultCard(
                product: product,
                onTap: () => context.push('/products/${product.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── 최근 검색어 칩 ──────────────────────────
class _RecentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentChip({required this.label, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.body2),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 13, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 검색 결과 카드 ──────────────────────────
class _SearchResultCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _SearchResultCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(_iconForCategory(product.category),
                        size: 44, color: AppColors.premiumPoint),
                    ),
                  ),
                  if (product.isSoldOut)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Center(
                          child: Text('SOLD OUT',
                            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700,
                              fontSize: 13, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                    style: const TextStyle(
                      fontFamily: 'Pretendard', fontSize: 12,
                      fontWeight: FontWeight.w500, color: AppColors.textMain,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(product.formattedPrice,
                    style: const TextStyle(
                      fontFamily: 'Pretendard', fontSize: 13,
                      fontWeight: FontWeight.w700, color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(ProductCategory category) {
    switch (category) {
      case ProductCategory.medicalDevice: return Icons.medical_services_outlined;
      case ProductCategory.diagnostic:    return Icons.biotech_outlined;
      case ProductCategory.beautyCare:    return Icons.spa_outlined;
      case ProductCategory.medicine:      return Icons.medication_outlined;
      case ProductCategory.health:        return Icons.health_and_safety_outlined;
    }
  }
}
