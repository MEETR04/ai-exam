import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../logic/dependency_provider.dart';
import '../../../presentation/theme/app_theme.dart';
import '../../../presentation/utils/app_bottom_sheet.dart';
import '../logic/invoice_list_controller.dart';
import '../logic/pdf_service.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../widgets/delete_confirmation_sheet.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final listController = DependencyProvider.of(context).listController;
    final pdfService = PdfService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF121828)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Invoice',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121828),
          ),
        ),
        centerTitle: true,
        actions: [
          8.horizontalSpace,
          // Delete button
          _AppBarAction(
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFFCB323D),
            bgColor: const Color(0xFFFEE7E8),
            onTap: () => _showDeleteConfirmation(context, listController),
          ),
          16.horizontalSpace,
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 32.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE9ECF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip
                  _StatusPill(status: invoice.status),
                  16.verticalSpace,

                  // Client name — 22px/700 #121828
                  Text(
                    invoice.clientName,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF121828),
                    ),
                  ),
                  12.verticalSpace,

                  // Amount row — ₹  450  .00  INR
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9AA1AD),
                        ),
                      ),
                      4.horizontalSpace,
                      Text(
                        invoice.grandTotal.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF121828),
                          height: 1,
                        ),
                      ),
                      Text(
                        '.${((invoice.grandTotal % 1) * 100).toInt().toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9AA1AD),
                        ),
                      ),
                      8.horizontalSpace,
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.r),
                        child: Text(
                          'INR',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9AA1AD),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Divider — 1px #E9ECF0
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.r),
                    child: Divider(
                      height: 1.r,
                      thickness: 1.r,
                      color: const Color(0xFFE9ECF0),
                    ),
                  ),

                  // Invoice number row
                  _InfoRow(
                    icon: Icons.tag_rounded,
                    label: 'Invoice number',
                    value: '#${invoice.invoiceNumber}',
                  ),
                  16.verticalSpace,

                  // Issued date row
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Issued',
                    value: DateFormat('MMM d, yyyy').format(invoice.date),
                  ),
                ],
              ),
            ),
            16.verticalSpace,

            // ── Line Items Card ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE9ECF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row — "Items" + count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF121828),
                        ),
                      ),
                      Text(
                        '${invoice.items.length} item${invoice.items.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9AA1AD),
                        ),
                      ),
                    ],
                  ),
                  16.verticalSpace,

                  // Item rows
                  ...invoice.items.map((item) => _buildLineItem(item)),

                  // Tax row
                  if (invoice.taxPercentage > 0) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.r),
                      child: Divider(
                        height: 1.r,
                        thickness: 1.r,
                        color: const Color(0xFFF3F4F6),
                      ),
                    ),
                    _buildTaxRow(invoice),
                  ],
                ],
              ),
            ),
            24.verticalSpace,

            // ── Action Buttons ────────────────────────────────────────────
            if (invoice.status != InvoiceStatus.paid) ...[
              SizedBox(
                width: double.infinity,
                height: 54.r,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final updated =
                        invoice.copyWith(status: InvoiceStatus.paid);
                    listController.updateInvoice(updated);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check_rounded,
                      size: 18.r, color: Colors.white),
                  label: Text(
                    'Mark as Paid',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10996B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              10.verticalSpace,
            ],

            // Download PDF — 48px #EDEFFF
            SizedBox(
              width: double.infinity,
              height: 48.r,
              child: ElevatedButton.icon(
                onPressed: () => pdfService.generateAndPrintInvoice(invoice),
                icon: Icon(
                  Icons.download_outlined,
                  size: 18.r,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Download PDF',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDEFFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    InvoiceListController listController,
  ) {
    AppBottomSheet.show(
      context,
      builder: (bottomSheetContext) => DeleteConfirmationSheet(
        invoice: invoice,
        onDelete: () {
          listController.deleteInvoice(invoice.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLineItem(InvoiceItem item) {
    return Padding(
      padding: EdgeInsets.only(top: 4.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF121828),
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  2.verticalSpace,
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6F7887),
                    ),
                  ),
                ],
                2.verticalSpace,
                Text(
                  'Qty ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9AA1AD),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxRow(Invoice invoice) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tax (${invoice.taxPercentage.toStringAsFixed(0)}%)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF121828),
            ),
          ),
          Text(
            '₹${invoice.taxAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF121828),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

/// AppBar icon button with colored circular background (matches Figma).
class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _AppBarAction({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.r, color: color),
      ),
    );
  }
}

/// Info row: [icon chip] [label]  [value] — matches Figma 28×28 #F8F9FB chip.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 14.r, color: const Color(0xFF6F7888)),
        ),
        10.horizontalSpace,
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6F7888),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121828),
          ),
        ),
      ],
    );
  }
}

/// Status pill — matches Figma node 5:645: #E5EAFF bg, radius:100, primary dot.
class _StatusPill extends StatelessWidget {
  final InvoiceStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, dotColor, textColor, bgColor) = switch (status) {
      InvoiceStatus.sent     => ('SENT',    AppColors.primary,           AppColors.primary,           const Color(0xFFE5EAFF)),
      InvoiceStatus.draft    => ('DRAFT',   const Color(0xFF9AA1AD),     const Color(0xFF9AA1AD),     const Color(0xFFF3F4F6)),
      InvoiceStatus.paid     => ('PAID',    const Color(0xFF10996B),     const Color(0xFF10996B),     const Color(0xFFE6F7F2)),
      InvoiceStatus.overdue  => ('OVERDUE', const Color(0xFFCB323D),     const Color(0xFFCB323D),     const Color(0xFFFEE7E8)),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          6.horizontalSpace,
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
