import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/invoice_item.dart';
import '../../../presentation/theme/app_theme.dart';
import '../../../presentation/utils/app_toast.dart';

class InvoiceItemSheet extends StatefulWidget {
  final Function(InvoiceItem) onAdd;
  final InvoiceItem? initialItem;

  const InvoiceItemSheet({
    super.key,
    required this.onAdd,
    this.initialItem,
  });

  @override
  State<InvoiceItemSheet> createState() => _InvoiceItemSheetState();
}

class _InvoiceItemSheetState extends State<InvoiceItemSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;
  late final ValueNotifier<double> _subtotalNotifier;

  final _nameFocus = FocusNode();
  final _descFocus = FocusNode();
  final _qtyFocus = FocusNode();
  final _priceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _descController = TextEditingController(text: item?.description ?? '');
    _qtyController = TextEditingController(text: item?.quantity.toString() ?? '1');
    _priceController = TextEditingController(text: item != null ? item.unitPrice.toStringAsFixed(2) : '');

    _subtotalNotifier = ValueNotifier(_computeSubtotal());
    _qtyController.addListener(_updateSubtotal);
    _priceController.addListener(_updateSubtotal);
  }

  double _computeSubtotal() {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    return qty * price;
  }

  void _updateSubtotal() => _subtotalNotifier.value = _computeSubtotal();

  @override
  void dispose() {
    _qtyController.removeListener(_updateSubtotal);
    _priceController.removeListener(_updateSubtotal);
    _nameController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _subtotalNotifier.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    _qtyFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (name.isNotEmpty && price > 0) {
      widget.onAdd(InvoiceItem(
        name: name,
        description: desc,
        quantity: qty,
        unitPrice: price,
      ));
      Navigator.pop(context);
    } else {
      AppToast.error(
        context,
        title: 'Invalid Item',
        description: 'Please enter a valid item name and price.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(top: 12.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ──────────────────────────────────────
          Center(
            child: Container(
              width: 40.r,
              height: 4.r,
              margin: EdgeInsets.only(bottom: 20.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EBF0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset + 24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header (with horizontal padding) ─────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit ? 'Edit Item' : 'Add Item',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF121826),
                                ),
                              ),
                              2.verticalSpace,
                              Text(
                                isEdit ? 'Update this line item' : 'Fill in the details below',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF9AA1AD),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close button — 32×32 #F3F4F6 circle
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.r,
                              color: const Color(0xFF6F7887),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.verticalSpace,

                  // ── Divider (Full Width) ──────────────────────
                  Divider(
                      height: 1.r,
                      thickness: 1.r,
                      color: const Color(0xFFE9EBF0)),

                  20.verticalSpace,

                  // ── Form Content (with horizontal padding) ────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── ITEM NAME ────────────────────────────────
                        _buildLabeledField(
                          label: 'ITEM NAME',
                          controller: _nameController,
                          focusNode: _nameFocus,
                          icon: Icons.category_outlined,
                          hint: 'e.g. Website design',
                        ),
                        12.verticalSpace,

                        // ── ITEM DESCRIPTION ─────────────────────────
                        _buildLabeledField(
                          label: 'ITEM DESCRIPTION',
                          controller: _descController,
                          focusNode: _descFocus,
                          icon: Icons.description_outlined,
                          hint: 'Landing page design with hero, features...',
                          maxLines: 2,
                        ),
                        12.verticalSpace,

                        // ── QUANTITY + PRICE/ITEM ────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _buildLabeledField(
                                label: 'QUANTITY',
                                controller: _qtyController,
                                focusNode: _qtyFocus,
                                icon: Icons.tag,
                                hint: '1',
                                isNumber: true,
                              ),
                            ),
                            12.horizontalSpace,
                            Expanded(
                              child: _buildLabeledField(
                                label: 'PRICE / ITEM',
                                controller: _priceController,
                                focusNode: _priceFocus,
                                icon: Icons.attach_money,
                                hint: '0.00',
                                isNumber: true,
                                suffix: 'INR',
                              ),
                            ),
                          ],
                        ),
                        16.verticalSpace,

                        // ── Item Subtotal Row ────────────────────────
                        ValueListenableBuilder<double>(
                          valueListenable: _subtotalNotifier,
                          builder: (context, subtotal, _) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.r, vertical: 14.r),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  // Blue dot
                                  Container(
                                    width: 8.r,
                                    height: 8.r,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  10.horizontalSpace,
                                  Text(
                                    'Item subtotal',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  4.horizontalSpace,
                                  Text(
                                    'INR',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        20.verticalSpace,

                        // ── Save / Add Button ────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 56.r,
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: Icon(
                              isEdit ? Icons.check : Icons.add,
                              size: 18.r,
                              color: Colors.white,
                            ),
                            label: Text(
                              isEdit ? 'Save Changes' : 'Add Item',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          ),
                        ),
                        8.verticalSpace,

                        // ── Cancel ───────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 50.r,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F4F6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF121826),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    bool isNumber = false,
    String? suffix,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: _focusNotifier(focusNode),
      builder: (context, isFocused, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF9AA1AD),
              ),
            ),
            6.verticalSpace,
            Container(
              constraints:
                  BoxConstraints(minHeight: maxLines > 1 ? 60.r : 42.r),
              padding: EdgeInsets.symmetric(horizontal: 14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isFocused ? AppColors.primary : const Color(0xFFE9EBF0),
                  width: isFocused ? 1.5.r : 1.r,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16.r,
                    color: isFocused ? AppColors.primary : const Color(0xFF9AA1AD),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      maxLines: maxLines,
                      keyboardType: isNumber
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.text,
                      inputFormatters: isNumber
                          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                          : null,
                      onSubmitted: (_) => focusNode.unfocus(),
                      onTapOutside: (_) => focusNode.unfocus(),
                      onEditingComplete: () => focusNode.unfocus(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF121826),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: const Color(0xFF9AA1AD),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.r),
                      ),
                    ),
                  ),
                  if (suffix != null) ...[
                    4.horizontalSpace,
                    Text(
                      suffix,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9AA1AD),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Converts a FocusNode into a ValueNotifier<bool> for reactive focus border
  ValueNotifier<bool> _focusNotifier(FocusNode node) {
    final notifier = ValueNotifier(node.hasFocus);
    node.addListener(() => notifier.value = node.hasFocus);
    return notifier;
  }
}
