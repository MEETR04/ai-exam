import 'package:flutter/material.dart';
import '../features/invoice/logic/invoice_list_controller.dart';
import '../features/invoice/logic/invoice_form_controller.dart';

class DependencyProvider extends InheritedWidget {
  final InvoiceListController listController;
  final InvoiceFormController formController;

  const DependencyProvider({
    super.key,
    required this.listController,
    required this.formController,
    required super.child,
  });

  static DependencyProvider of(BuildContext context) {
    final DependencyProvider? result = context.dependOnInheritedWidgetOfExactType<DependencyProvider>();
    assert(result != null, 'No DependencyProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(DependencyProvider oldWidget) => false;
}
