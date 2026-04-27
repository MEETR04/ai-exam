import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

/// Centralized toast utility — wraps [toastification] with app-wide defaults.
/// All toasts appear from the **top**, auto-dismiss after 3 s.
/// Uses [ToastificationStyle.fillColored] for vivid, non-washed-out colors.
class AppToast {
  AppToast._();

  static const Duration _duration = Duration(seconds: 3);
  static const Alignment _alignment = Alignment.topCenter;

  // ── Dedup guard: prevent same-type toast flooding ──────────────────────────
  static ToastificationType? _lastType;
  static DateTime? _lastShown;
  static const Duration _dedupWindow = Duration(milliseconds: 800);

  static bool _isDuplicate(ToastificationType type) {
    final now = DateTime.now();
    if (_lastType == type &&
        _lastShown != null &&
        now.difference(_lastShown!) < _dedupWindow) {
      return true;
    }
    _lastType = type;
    _lastShown = now;
    return false;
  }

  // ── Success — Primary blue ─────────────────────────────────────────────────
  static void success(
    BuildContext context, {
    required String title,
    String? description,
  }) {
    if (_isDuplicate(ToastificationType.success)) return;
    _show(
      context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: title,
      description: description,
      primaryColor: const Color(0xFF1B32F2),
    );
  }

  // ── Error — Red ───────────────────────────────────────────────────────────
  static void error(
    BuildContext context, {
    required String title,
    String? description,
  }) {
    if (_isDuplicate(ToastificationType.error)) return;
    _show(
      context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: title,
      description: description,
      primaryColor: const Color(0xFFCB323D),
    );
  }

  // ── Warning — Amber ───────────────────────────────────────────────────────
  static void warning(
    BuildContext context, {
    required String title,
    String? description,
  }) {
    if (_isDuplicate(ToastificationType.warning)) return;
    _show(
      context,
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      title: title,
      description: description,
      primaryColor: const Color(0xFFF59E0B),
    );
  }

  // ── Info — Blue ───────────────────────────────────────────────────────────
  static void info(
    BuildContext context, {
    required String title,
    String? description,
  }) {
    if (_isDuplicate(ToastificationType.info)) return;
    _show(
      context,
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      title: title,
      description: description,
      primaryColor: const Color(0xFF1B32F2),
    );
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  static void _show(
    BuildContext context, {
    required ToastificationType type,
    required ToastificationStyle style,
    required String title,
    String? description,
    required Color primaryColor,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: style,
      alignment: _alignment,
      autoCloseDuration: _duration,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      description: description != null
          ? Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            )
          : null,
      primaryColor: primaryColor,
      borderRadius: BorderRadius.circular(14.r),
      showProgressBar: true,
      closeOnClick: false,
      pauseOnHover: true,
    );
  }
}
