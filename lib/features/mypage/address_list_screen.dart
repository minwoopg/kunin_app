import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../core/providers/address_provider.dart';
import '../../data/models/address_model.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/state_views.dart';

class AddressListScreen extends ConsumerWidget {
  /// true면 "배송지 선택" 모드로 동작 — 주소를 탭하면 곧바로 그 주소를 결과로 반환하며
  /// 화면을 닫습니다. 주문서 작성 화면에서 배송지를 고를 때 이 모드로 진입합니다.
  final bool selectMode;

  const AddressListScreen({super.key, this.selectMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(selectMode ? '배송지 선택' : '배송지 관리 (${addresses.length})'),
      ),
      body: addresses.isEmpty
          ? EmptyStateView(
              icon: Icons.location_on_outlined,
              title: '등록된 배송지가 없습니다',
              subtitle: '자주 쓰는 배송지를 등록해두면 편리해요',
              buttonLabel: '배송지 추가',
              onButtonTap: () => context.push(AppRoutes.addressForm),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 90,
              ),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final address = addresses[i];
                return _AddressCard(
                  address: address,
                  selectMode: selectMode,
                  onSelect: () => context.pop(address),
                  onEdit: () => context.push(AppRoutes.addressForm, extra: address),
                  onDelete: () => _showDeleteDialog(context, ref, address),
                  onSetDefault: () => ref.read(addressProvider.notifier).setDefault(address.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addressForm),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('배송지 추가'),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('배송지 삭제', style: AppTextStyles.h3),
        content: Text('"${address.label}" 배송지를 삭제하시겠습니까?', style: AppTextStyles.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              ref.read(addressProvider.notifier).remove(address.id);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── 배송지 카드 ──────────────────────────
class _AddressCard extends StatelessWidget {
  final Address address;
  final bool selectMode;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.selectMode,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: selectMode ? onSelect : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: address.isDefault ? AppColors.primary : AppColors.border,
            width: address.isDefault ? 1.2 : 0.8,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(address.label,
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Text('기본배송지',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.white),
                    ),
                  ),
                ],
                const Spacer(),
                if (!selectMode)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSub),
                    color: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit': onEdit(); break;
                        case 'default': onSetDefault(); break;
                        case 'delete': onDelete(); break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('수정', style: AppTextStyles.body2)),
                      if (!address.isDefault)
                        const PopupMenuItem(value: 'default', child: Text('기본 배송지로 설정', style: AppTextStyles.body2)),
                      const PopupMenuItem(value: 'delete', child: Text('삭제', style: TextStyle(fontSize: 13, color: AppColors.error))),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(address.receiverName, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(address.phone, style: AppTextStyles.body2),
              ],
            ),
            const SizedBox(height: 4),
            Text(address.fullAddress, style: AppTextStyles.body2),
            if (selectMode) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Text('탭하여 선택',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
