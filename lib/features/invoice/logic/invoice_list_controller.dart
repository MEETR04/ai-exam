import 'package:flutter/material.dart';
import '../models/invoice.dart';
import 'storage_service.dart';

class InvoiceListController extends ChangeNotifier {
  final StorageService _storageService;
  List<Invoice> _invoices = [];
  bool _isLoading = false;

  InvoiceListController(this._storageService);

  List<Invoice> get invoices => List.unmodifiable(_invoices);
  bool get isLoading => _isLoading;

  /// Load all invoices from local storage.
  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();
    _invoices = await _storageService.getInvoices();
    _isLoading = false;
    notifyListeners();
  }

  /// Add a new invoice to the list and persist it.
  Future<void> addInvoice(Invoice invoice) async {
    _invoices.add(invoice);
    await _storageService.saveInvoices(_invoices);
    notifyListeners();
  }

  /// Delete an invoice by its ID and update storage.
  Future<void> deleteInvoice(String id) async {
    _invoices.removeWhere((i) => i.id == id);
    await _storageService.saveInvoices(_invoices);
    notifyListeners();
  }

  /// Update an existing invoice.
  Future<void> updateInvoice(Invoice invoice) async {
    final index = _invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
      await _storageService.saveInvoices(_invoices);
      notifyListeners();
    }
  }
}
