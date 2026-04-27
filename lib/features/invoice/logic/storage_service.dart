import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';

class StorageService {
  static const String _key = 'invoices';

  /// Save the entire list of invoices to local storage.
  Future<void> saveInvoices(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(invoices.map((i) => i.toJson()).toList());
    await prefs.setString(_key, data);
  }

  /// Retrieve the list of invoices from local storage.
  Future<List<Invoice>> getInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((i) => Invoice.fromJson(i as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading invoices: $e');
      return [];
    }
  }

  /// Convenience method to add a single invoice.
  Future<void> addInvoice(Invoice invoice) async {
    final invoices = await getInvoices();
    invoices.add(invoice);
    await saveInvoices(invoices);
  }

  /// Convenience method to delete an invoice by ID.
  Future<void> deleteInvoice(String id) async {
    final invoices = await getInvoices();
    invoices.removeWhere((i) => i.id == id);
    await saveInvoices(invoices);
  }
}
