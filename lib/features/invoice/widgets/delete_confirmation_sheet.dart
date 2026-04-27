import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/invoice.dart';
import '../../../presentation/theme/app_theme.dart';

class DeleteConfirmationSheet extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onDelete;

  const DeleteConfirmationSheet({
    super.key,
    required this.invoice,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: 12.r, bottom: 0),
            child: Center(
              child: Container(
                width: 40.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EBF0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),

          // ── Icon + Title + Description ────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, 0),
            child: Column(
              children: [
                // Trash icon circle — 56×56, #FEE7E8
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE7E8),
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: const Color(0xFFCB323D),
                    size: 24.r,
                  ),
                ),
                16.verticalSpace,

                // Title — 20px/700 #121828
                Text(
                  'Delete Invoice?',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF121828),
                  ),
                ),
                8.verticalSpace,

                // Description — 14px/400 #6F7888
                Text(
                  'Are you sure you want to delete this invoice? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6F7888),
                    height: 1.5,
                  ),
                ),
                24.verticalSpace,
              ],
            ),
          ),

          // ── Full-Width Divider — 1px #E9EBF0 ─────────────────────────
          Divider(height: 1.r, thickness: 1.r, color: const Color(0xFFE9EBF0)),

          // ── Invoice Summary Card ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 0),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE9EBF0)),
              ),
              child: Row(
                children: [
                  // Icon chip — 32×32 #EDEFFF radius:10
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEFFF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.primary,
                      size: 16.r,
                    ),
                  ),
                  12.horizontalSpace,

                  // Client name + invoice number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.clientName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF121828),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        2.verticalSpace,
                        Text(
                          '#${invoice.invoiceNumber}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9AA1AD),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount — 13px/600 #121828
                  Text(
                    '₹${invoice.grandTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF121828),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Buttons ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 0),
            child: Column(
              children: [
                // Delete — 54px, radius:14, #CB323D
                SizedBox(
                  width: double.infinity,
                  height: 54.r,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onDelete();
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18.r,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCB323D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
                10.verticalSpace,

                // Cancel — 50px, radius:14, #F3F4F6
                SizedBox(
                  width: double.infinity,
                  height: 50.r,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF121828),
                      ),
                    ),
                  ),
                ),

                // Home indicator spacing
                24.verticalSpace,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
