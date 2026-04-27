import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';

class PdfService {
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  
  /// Formatter for INR Currency (₹)
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '₹',
    locale: 'en_IN',
    decimalDigits: 2,
  );

  /// Generates a PDF document and opens the print/preview dialog.
  Future<void> generateAndPrintInvoice(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${invoice.invoiceNumber}'),
                      pw.Text('Date: ${_dateFormatter.format(invoice.date)}'),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 40),

              // Client Information
              pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text(invoice.clientName, style: const pw.TextStyle(fontSize: 12)),
              
              pw.SizedBox(height: 30),

              // Line Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _buildHeaderCell('Description'),
                      _buildHeaderCell('Qty', align: pw.TextAlign.center),
                      _buildHeaderCell('Unit Price', align: pw.TextAlign.right),
                      _buildHeaderCell('Total', align: pw.TextAlign.right),
                    ],
                  ),
                  // Items
                  ...invoice.items.map((item) => pw.TableRow(
                    children: [
                      _buildCell(
                        item.description.isNotEmpty
                            ? '${item.name}\n${item.description}'
                            : item.name,
                      ),
                      _buildCell(item.quantity.toString(), align: pw.TextAlign.center),
                      _buildCell(_currencyFormatter.format(item.unitPrice), align: pw.TextAlign.right),
                      _buildCell(_currencyFormatter.format(item.totalPrice), align: pw.TextAlign.right),
                    ],
                  )),
                ],
              ),

              pw.SizedBox(height: 30),

              // Totals Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildTotalRow('Subtotal:', _currencyFormatter.format(invoice.subtotal)),
                      _buildTotalRow('Tax (18%):', _currencyFormatter.format(invoice.taxAmount)),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                        child: pw.Row(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(
                              'Grand Total: ',
                              style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(
                              _currencyFormatter.format(invoice.grandTotal),
                              style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.Text('Thank you for your business!', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    // This will open a preview & print dialog on mobile/desktop/web
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${invoice.invoiceNumber}.pdf',
    );
  }

  pw.Widget _buildHeaderCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  pw.Widget _buildCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(width: 20),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
