import 'package:flutter_test/flutter_test.dart';
import 'package:ai_exam/features/invoice/models/invoice.dart';
import 'package:ai_exam/features/invoice/models/invoice_item.dart';

void main() {
  group('Invoice Calculations', () {
    test('subtotal should be correct', () {
      final item1 = InvoiceItem(name: 'Test Item 1', quantity: 2, unitPrice: 100);
      final item2 = InvoiceItem(name: 'Test Item 2', quantity: 1, unitPrice: 50);
      
      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-1',
        clientName: 'Client',
        date: DateTime.now(),
        items: [item1, item2],
      );

      // (2 * 100) + (1 * 50) = 250
      expect(invoice.subtotal, 250.0);
    });

    test('tax and grand total should be correct based on 18% tax', () {
      final item = InvoiceItem(name: 'Test Service', quantity: 1, unitPrice: 1000);
      
      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-1',
        clientName: 'Client',
        date: DateTime.now(),
        items: [item],
      );

      // subtotal = 1000
      // tax = 1000 * 0.18 = 180
      // grandTotal = 1180
      expect(invoice.taxAmount, 180.0);
      expect(invoice.grandTotal, 1180.0);
    });

    test('JSON serialization should preserve data', () {
      final item = InvoiceItem(name: 'Test', description: 'Test desc', quantity: 5, unitPrice: 20);
      final invoice = Invoice(
        id: 'unique-id',
        invoiceNumber: 'INV-2024',
        clientName: 'John Doe',
        date: DateTime(2024, 1, 1),
        items: [item],
        status: InvoiceStatus.paid,
      );

      final json = invoice.toJson();
      final fromJson = Invoice.fromJson(json);

      expect(fromJson.id, invoice.id);
      expect(fromJson.clientName, invoice.clientName);
      expect(fromJson.items.first.name, item.name);
      expect(fromJson.items.first.description, item.description);
      expect(fromJson.status, InvoiceStatus.paid);
      expect(fromJson.grandTotal, invoice.grandTotal);
    });
  });
}
