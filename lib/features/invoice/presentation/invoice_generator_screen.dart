import 'package:ai_exam/logic/dependency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../presentation/theme/app_theme.dart';
import '../../../presentation/utils/app_bottom_sheet.dart';
import '../../../presentation/utils/app_toast.dart';
import '../logic/invoice_form_controller.dart';
import '../logic/invoice_list_controller.dart';
import '../logic/pdf_service.dart';
import '../models/invoice_item.dart';
import '../widgets/invoice_item_sheet.dart';

class InvoiceGeneratorScreen extends StatefulWidget {
  const InvoiceGeneratorScreen({super.key});

  @override
  State<InvoiceGeneratorScreen> createState() => _InvoiceGeneratorScreenState();
}

class _InvoiceGeneratorScreenState extends State<InvoiceGeneratorScreen> {
  late InvoiceFormController _formController;
  late InvoiceListController _listController;
  final PdfService _pdfService = PdfService();
  final TextEditingController _clientNameController = TextEditingController();
  final FocusNode _clientNameFocus = FocusNode();
  final TextEditingController _taxController = TextEditingController(
    text: '18',
  );
  final FocusNode _taxFocus = FocusNode();

  /// Debounce guard — true while an invoice generation is in progress.
  final ValueNotifier<bool> _isGenerating = ValueNotifier(false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formController = DependencyProvider.of(context).formController;
    _listController = DependencyProvider.of(context).listController;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientNameFocus.dispose();
    _taxController.dispose();
    _taxFocus.dispose();
    _isGenerating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Custom Header ──────────────────────────────────────
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Invoice Generator',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF121826),
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      'Create invoices in seconds',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6F7887),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Scrollable Content ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Client Details Card ─────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFE9EBF0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client Details',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF121826),
                            ),
                          ),
                          10.verticalSpace,
                          Text(
                            'CLIENT NAME',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9AA1AD),
                            ),
                          ),
                          6.verticalSpace,
                          Container(
                            height: 42.r,
                            padding: EdgeInsets.symmetric(horizontal: 14.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE9EBF0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16.r,
                                  color: const Color(0xFF9AA1AD),
                                ),
                                10.horizontalSpace,
                                Expanded(
                                  child: TextField(
                                    controller: _clientNameController,
                                    focusNode: _clientNameFocus,
                                    onChanged: _formController.setClientName,
                                    onTapOutside: (_) =>
                                        _clientNameFocus.unfocus(),
                                    onSubmitted: (_) =>
                                        _clientNameFocus.unfocus(),
                                    onEditingComplete: () =>
                                        _clientNameFocus.unfocus(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF121826),
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'e.g. Acme Studios Inc.',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFF9AA1AD),
                                        fontSize: 14.sp,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.verticalSpace,

                    // ── Item Details Card ───────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFE9EBF0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Item Details',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF121826),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showAddItemSheet(context),
                                child: Text(
                                  '+ Add item',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          10.verticalSpace,
                          // Line items list
                          ListenableBuilder(
                            listenable: _formController,
                            builder: (context, _) {
                              if (_formController.items.isEmpty) {
                                return _buildEmptyItems();
                              }
                              return Column(
                                children: List.generate(
                                  _formController.items.length,
                                  (index) {
                                    final item = _formController.items[index];
                                    return _buildLineItem(item, index);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    10.verticalSpace,
                    10.verticalSpace,
                    // ── Tax Details Card ────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFE9EBF0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAX',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF121826),
                            ),
                          ),
                          10.verticalSpace,
                          Container(
                            height: 42.r,
                            padding: EdgeInsets.symmetric(horizontal: 14.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE9EBF0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _taxController,
                                    focusNode: _taxFocus,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (val) {
                                      final tax = double.tryParse(val) ?? 0.0;
                                      _formController.setTaxPercentage(tax);
                                    },
                                    onTapOutside: (_) => _taxFocus.unfocus(),
                                    onSubmitted: (_) => _taxFocus.unfocus(),
                                    onEditingComplete: () =>
                                        _taxFocus.unfocus(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF121826),
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      suffixText: '%',
                                      suffixStyle: TextStyle(
                                        color: const Color(0xFF9AA1AD),
                                        fontSize: 14.sp,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    10.verticalSpace,
                    // ── Summary Card ────────────────────────────────
                    ListenableBuilder(
                      listenable: _formController,
                      builder: (context, _) {
                        return _buildSummaryCard();
                      },
                    ),

                    10.verticalSpace,

                    // ── Action Buttons ──────────────────────────────
                    ValueListenableBuilder<bool>(
                      valueListenable: _isGenerating,
                      builder: (context, isGenerating, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50.r,
                          child: ElevatedButton.icon(
                            onPressed: isGenerating
                                ? null
                                : () async {
                                    // Validation — no debounce needed for warnings
                                    if (_formController.clientName.isEmpty ||
                                        _formController.items.isEmpty) {
                                      AppToast.warning(
                                        context,
                                        title: 'Missing Information',
                                        description:
                                            'Please add client name and at least one item.',
                                      );
                                      return;
                                    }

                                    // Lock button immediately
                                    _isGenerating.value = true;
                                    try {
                                      final invoice = _formController
                                          .generateInvoice();
                                      await _listController.addInvoice(invoice);
                                      _formController.reset();
                                      _clientNameController.clear();
                                      if (!context.mounted) return;
                                      AppToast.success(
                                        context,
                                        title: 'Invoice Generated!',
                                        description:
                                            '${invoice.invoiceNumber} has been saved.',
                                      );
                                    } finally {
                                      _isGenerating.value = false;
                                    }
                                  },
                            icon: isGenerating
                                ? SizedBox(
                                    width: 16.r,
                                    height: 16.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.description_outlined,
                                    size: 16.r,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              isGenerating
                                  ? 'Generating...'
                                  : 'Generate Invoice',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                          ),
                        );
                      },
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44.r,
                            child: OutlinedButton.icon(
                              onPressed: () => _showAddItemSheet(context),
                              icon: Icon(
                                Icons.add,
                                size: 14.r,
                                color: const Color(0xFF121826),
                              ),
                              label: Text(
                                'Add Item',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF121826),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: const Color(0xFFE9EBF0),
                                  width: 1.5.r,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.r,
                                ),
                              ),
                            ),
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: SizedBox(
                            height: 44.r,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_formController.items.isNotEmpty) {
                                  _pdfService.generateAndPrintInvoice(
                                    _formController.generateInvoice(),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.download_outlined,
                                size: 14.r,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'Download PDF',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFECF0FF),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.r,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    100.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItems() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.r),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: const Color(0xFF9AA1AD),
              size: 32.r,
            ),
            8.verticalSpace,
            Text(
              'No items added yet',
              style: TextStyle(
                  color: const Color(0xFF9AA1AD), fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(InvoiceItem item, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: ITEM pill + Subtotal + Delete ─────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ITEM N pill
              Container(
                padding: EdgeInsets.fromLTRB(8.r, 4.r, 10.r, 4.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFECF0FF),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  item.name.length > 14
                      ? '${item.name.substring(0, 14)}…'
                      : item.name,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9AA1AD),
                ),
              ),
              4.horizontalSpace,
              Text(
                '₹${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF121826),
                ),
              ),
              8.horizontalSpace,
              // Delete btn — 28×28 #F3F4F6 radius:8
              GestureDetector(
                onTap: () => _formController.removeItem(index),
                child: Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 14.r,
                    color: const Color(0xFF6F7887),
                  ),
                ),
              ),
            ],
          ),
          8.verticalSpace,

          // ── Row 2: DESCRIPTION field ──────────────────────────
          Text(
            'DESCRIPTION',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9AA1AD),
            ),
          ),
          6.verticalSpace,
          GestureDetector(
            onTap: () => _showEditItemSheet(context, item, index),
            child: Container(
              height: 42.r,
              padding: EdgeInsets.symmetric(horizontal: 14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE9EBF0)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16.r,
                    color: AppColors.primary,
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: Text(
                      item.description.isNotEmpty
                          ? item.description
                          : 'No description',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: item.description.isNotEmpty
                            ? const Color(0xFF121826)
                            : const Color(0xFF9AA1AD),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          8.verticalSpace,

          // ── Row 3: QUANTITY + PRICE/ITEM side by side ─────────
          Row(
            children: [
              // Quantity column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUANTITY',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9AA1AD),
                      ),
                    ),
                    6.verticalSpace,
                    GestureDetector(
                      onTap: () => _showEditItemSheet(context, item, index),
                      child: Container(
                        height: 42.r,
                        padding: EdgeInsets.symmetric(horizontal: 14.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE9EBF0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tag,
                              size: 14.r,
                              color: const Color(0xFF9AA1AD),
                            ),
                            8.horizontalSpace,
                            Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF121826),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.horizontalSpace,
              // Price column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRICE / ITEM',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9AA1AD),
                      ),
                    ),
                    6.verticalSpace,
                    GestureDetector(
                      onTap: () => _showEditItemSheet(context, item, index),
                      child: Container(
                        height: 42.r,
                        padding: EdgeInsets.symmetric(horizontal: 14.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE9EBF0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 14.r,
                              color: const Color(0xFF9AA1AD),
                            ),
                            4.horizontalSpace,
                            Text(
                              item.unitPrice.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF121826),
                              ),
                            ),
                            4.horizontalSpace,
                            Text(
                              'USD',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF9AA1AD),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final total = _formController.total;
    final intPart = total.truncate().toString();
    final decPart =
        '.${(total % 1 * 100).abs().truncate().toString().padLeft(2, '0')}';
    final itemCount = _formController.items.length;

    // Build footer summary text
    final summaryText = itemCount == 0
        ? 'No items added'
        : '$itemCount item${itemCount == 1 ? '' : 's'} · Qty ${_formController.items.fold(0, (s, i) => s + i.quantity)} × ₹${_formController.items.isNotEmpty ? _formController.items.first.unitPrice.toStringAsFixed(2) : '0.00'}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Label + LIVE badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      color: const Color(0xFF99A6BF),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    'Auto-calculated',
                    style: TextStyle(
                      color: const Color(0xFF8C99B2),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // LIVE pill — green background
              Container(
                padding: EdgeInsets.fromLTRB(7.r, 3.r, 9.r, 3.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF10BA81),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 10.r, color: Colors.white),
                    3.horizontalSpace,
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.verticalSpace,

          // Row 2: Amount display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // ₹ prefix
              Text(
                '₹',
                style: TextStyle(
                  color: const Color(0xFF99A6BF),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              3.horizontalSpace,
              // Integer part
              Text(
                intPart,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              // Decimal part
              Text(
                decPart,
                style: TextStyle(
                  color: const Color(0xFF99A6BF),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Currency label
              Text(
                'INR',
                style: TextStyle(
                  color: const Color(0xFF99A6BF),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          10.verticalSpace,

          // Divider — white at 8% opacity
          Container(
            width: double.infinity,
            height: 1.r,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          10.verticalSpace,

          // Row 3: Summary footer
          Row(
            children: [
              Text(
                summaryText,
                style: TextStyle(
                  color: const Color(0xFF99A6BF),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                'GST ${_formController.taxPercentage.toStringAsFixed(0)}% · ₹${_formController.taxAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: const Color(0xFF8C99B2),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    AppBottomSheet.show(
      context,
      builder: (context) =>
          InvoiceItemSheet(onAdd: (item) => _formController.addItem(item)),
    );
  }

  void _showEditItemSheet(BuildContext context, InvoiceItem item, int index) {
    AppBottomSheet.show(
      context,
      builder: (context) => InvoiceItemSheet(
        initialItem: item,
        onAdd: (updatedItem) => _formController.updateItem(index, updatedItem),
      ),
    );
  }
}
