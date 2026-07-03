import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/address_provider.dart';
import '../../data/models/address_model.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/primary_button.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  /// null이면 새 배송지 추가, 값이 있으면 해당 배송지 수정
  final Address? existing;

  const AddressFormScreen({super.key, this.existing});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  late final TextEditingController _labelController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _detailController;
  late bool _isDefault;

  bool get _isEditing => widget.existing != null;

  static const _quickLabels = ['집', '회사', '기타'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _labelController   = TextEditingController(text: existing?.label ?? '집');
    _nameController     = TextEditingController(text: existing?.receiverName ?? '');
    _phoneController    = TextEditingController(text: existing?.phone ?? '');
    _addressController  = TextEditingController(text: existing?.address ?? '');
    _detailController   = TextEditingController(text: existing?.addressDetail ?? '');
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _save() {
    final label   = _labelController.text.trim();
    final name    = _nameController.text.trim();
    final phone   = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (label.isEmpty || name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지 별칭, 받는사람, 연락처, 주소를 모두 입력해주세요.')),
      );
      return;
    }

    final notifier = ref.read(addressProvider.notifier);

    if (_isEditing) {
      notifier.update(widget.existing!.copyWith(
        label: label,
        receiverName: name,
        phone: phone,
        address: address,
        addressDetail: _detailController.text.trim(),
        isDefault: _isDefault,
      ));
    } else {
      notifier.add(Address(
        id: notifier.generateId(),
        label: label,
        receiverName: name,
        phone: phone,
        address: address,
        addressDetail: _detailController.text.trim(),
        isDefault: _isDefault,
      ));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? '배송지 수정' : '배송지 추가')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('배송지 별칭', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _labelController,
              style: AppTextStyles.body1,
              decoration: const InputDecoration(hintText: '예) 집, 회사'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: _quickLabels.map((label) {
                return ActionChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  onPressed: () => setState(() => _labelController.text = label),
                  backgroundColor: AppColors.cardBackground,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('받는 사람', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              style: AppTextStyles.body1,
              decoration: const InputDecoration(hintText: '이름을 입력해주세요'),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('연락처', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _phoneController,
              style: AppTextStyles.body1,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '010-0000-0000'),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('주소', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _addressController,
              style: AppTextStyles.body1,
              decoration: const InputDecoration(hintText: '도로명 주소를 입력해주세요'),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('상세 주소 (선택)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _detailController,
              style: AppTextStyles.body1,
              decoration: const InputDecoration(hintText: '동/호수 등 상세 주소'),
            ),
            const SizedBox(height: AppSpacing.lg),

            InkWell(
              onTap: () => setState(() => _isDefault = !_isDefault),
              child: Row(
                children: [
                  Icon(
                    _isDefault ? Icons.check_box : Icons.check_box_outline_blank,
                    color: _isDefault ? AppColors.primary : AppColors.textHint,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('기본 배송지로 설정', style: AppTextStyles.body1),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            PrimaryButton(
              label: _isEditing ? '수정 완료' : '배송지 저장',
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
