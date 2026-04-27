import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class InvoiceFormController extends ChangeNotifier {
  String _clientName = '';
  List<InvoiceItem> _items = [];
  DateTime _date = DateTime.now();
  double _taxPercentage = 18.0;

  String get clientName => _clientName;
  List<InvoiceItem> get items => _items;
  DateTime get date => _date;
  double get taxPercentage => _taxPercentage;

  void setClientName(String name) {
    _clientName = name;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  void setTaxPercentage(double value) {
    _taxPercentage = value;
    notifyListeners();
  }

  /// Add a line item to the draft.
  void addItem(InvoiceItem item) {
    _items.add(item);
    notifyListeners();
  }

  /// Remove a line item at a specific index.
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Update an existing item's quantity or price.
  void updateItem(int index, InvoiceItem newItem) {
    if (index >= 0 && index < _items.length) {
      _items[index] = newItem;
      notifyListeners();
    }
  }

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get taxAmount => subtotal * (_taxPercentage / 100); 
  double get total => subtotal + taxAmount;

  /// Generate a final Invoice model from the form state.
  Invoice generateInvoice() {
    return Invoice(
      id: const Uuid().v4(),
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}', // Random/Unique ID
      clientName: _clientName,
      date: _date,
      items: List.from(_items),
      status: InvoiceStatus.draft,
      taxPercentage: _taxPercentage,
    );
  }

  /// Clear the form state.
  void reset() {
    _clientName = '';
    _items = [];
    _date = DateTime.now();
    notifyListeners();
  }
}
