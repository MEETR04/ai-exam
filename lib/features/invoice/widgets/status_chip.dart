import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/invoice.dart';

class StatusChip extends StatelessWidget {
  final InvoiceStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case InvoiceStatus.paid:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        text = 'PAID';
        break;
      case InvoiceStatus.sent:
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF3730A3);
        text = 'SENT';
        break;
      case InvoiceStatus.draft:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
        text = 'DRAFT';
        break;
      case InvoiceStatus.overdue:
        bgColor = const Color(0xFFFEE7E8);
        textColor = const Color(0xFFCB323D);
        text = 'OVERDUE';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
