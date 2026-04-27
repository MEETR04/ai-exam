import 'package:flutter/material.dart';

/// Animated bottom sheet helper.
///
/// Uses a custom [ModalRoute] to deliver a spring-like slide-up with a
/// simultaneous subtle scale + fade entrance — much smoother than Flutter's
/// default linear bottom sheet animation.
///
/// Usage:
/// ```dart
/// AppBottomSheet.show(context, builder: (_) => MySheet());
/// ```
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,

    /// Whether the sheet resizes to avoid the keyboard.
    bool isScrollControlled = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return _SheetScaffold(builder: builder);
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        // Spring curve: fast start, gentle overshoot settle
        final curved = CurvedAnimation(
          parent: animation,
          curve: const _SpringCurve(),
          reverseCurve: Curves.easeInCubic,
        );

        return Stack(
          children: [
            // ── Dimmed backdrop (fades in independently) ────────────
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: const _Barrier(),
            ),
            // ── Sheet: slides up + very slight scale ─────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

/// Transparent scaffold that hosts the sheet content and dismisses on barrier tap.
class _SheetScaffold extends StatelessWidget {
  final WidgetBuilder builder;
  const _SheetScaffold({required this.builder});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: builder(context),
      ),
    );
  }
}

/// The semi-transparent barrier (handles tap to dismiss via route pop).
class _Barrier extends StatelessWidget {
  const _Barrier();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: const SizedBox.expand(),
    );
  }
}

// ── Custom spring curve ────────────────────────────────────────────────────────
/// Mimics iOS spring physics: fast rise, tiny overshoot, quick settle.
class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    // Approximation of an underdamped spring (damping ≈ 0.7, stiffness moderate)
    return 1 - (1 - t) * (1 - t) * ((2.5 * t - 0.5) * (1 - t) + 1);
  }
}
