import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/order_provider.dart';
import '../../shared/theme/app_theme.dart';

class MypageScreen extends ConsumerStatefulWidget {
  const MypageScreen({super.key});

  @override
  ConsumerState<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends ConsumerState<MypageScreen> {
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final email = await AuthService.instance.getUserEmail();
    if (mounted) setState(() => _email = email);
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('로그아웃', style: AppTextStyles.h3),
        content: const Text('로그아웃 하시겠습니까?', style: AppTextStyles.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.logout();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderCount = ref.watch(orderProvider).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('마이페이지')),
      body: ListView(
        children: [
          // 프로필 영역
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.premiumPoint.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, color: AppColors.primaryPressed, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_email ?? '회원',
                        style: AppTextStyles.h3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text('KIP 멤버십 회원', style: AppTextStyles.body2),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('정보수정', style: AppTextStyles.caption),
                  ),
                ),
              ],
            ),
          ),

          // 주문 현황 요약
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.orderHistory),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _OrderStatItem(
                        icon: Icons.receipt_long_outlined,
                        label: '주문내역',
                        value: '$orderCount',
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    const Expanded(
                      child: _OrderStatItem(
                        icon: Icons.local_shipping_outlined,
                        label: '배송중',
                        value: '0',
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    const Expanded(
                      child: _OrderStatItem(
                        icon: Icons.replay_outlined,
                        label: '취소/반품',
                        value: '0',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 쇼핑 정보
          _MenuSection(
            title: '쇼핑 정보',
            items: [
              _MenuItemData(
                icon: Icons.receipt_long_outlined,
                label: '주문내역',
                onTap: () => context.push(AppRoutes.orderHistory),
              ),
              _MenuItemData(
                icon: Icons.location_on_outlined,
                label: '배송지 관리',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.favorite_border,
                label: '찜한 상품',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.history,
                label: '최근 본 상품',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 고객센터
          _MenuSection(
            title: '고객센터',
            items: [
              _MenuItemData(
                icon: Icons.campaign_outlined,
                label: '공지사항',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.help_outline,
                label: '자주 묻는 질문',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.chat_bubble_outline,
                label: '1:1 문의',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 계정
          _MenuSection(
            title: '계정',
            items: [
              _MenuItemData(
                icon: Icons.lock_outline,
                label: '비밀번호 변경',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.logout,
                label: '로그아웃',
                onTap: _onLogout,
                isDestructive: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 앱 버전
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text('KIP 2026 v1.0.0', style: AppTextStyles.caption),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 주문 현황 아이템 ──────────────────────
class _OrderStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OrderStatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.h3),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// ── 메뉴 섹션 ──────────────────────────────
class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItemData> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(title, style: AppTextStyles.label),
            ),
            for (int i = 0; i < items.length; i++) ...[
              _MenuItem(data: items[i]),
              if (i != items.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final _MenuItemData data;
  const _MenuItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.isDestructive ? AppColors.error : AppColors.textMain;
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(data.icon, size: 20, color: data.isDestructive ? AppColors.error : AppColors.textSub),
            const SizedBox(width: 14),
            Expanded(child: Text(data.label, style: AppTextStyles.body1.copyWith(color: color))),
            if (!data.isDestructive)
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
