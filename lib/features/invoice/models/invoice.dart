import 'invoice_item.dart';

enum InvoiceStatus { draft, sent, paid, overdue }

class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final DateTime date;
  final List<InvoiceItem> items;
  final InvoiceStatus status;
  final double taxPercentage;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.date,
    required this.items,
    this.status = InvoiceStatus.draft,
    this.taxPercentage = 18.0,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get taxAmount => subtotal * (taxPercentage / 100); 
  double get grandTotal => subtotal + taxAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'clientName': clientName,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'status': status.name,
        'taxPercentage': taxPercentage,
      };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        invoiceNumber: json['invoiceNumber'],
        clientName: json['clientName'],
        date: DateTime.parse(json['date']),
        items: (json['items'] as List)
            .map((i) => InvoiceItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        status: InvoiceStatus.values.byName(json['status']),
        taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 18.0,
      );

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? clientName,
    DateTime? date,
    List<InvoiceItem>? items,
    InvoiceStatus? status,
    double? taxPercentage,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      items: items ?? this.items,
      status: status ?? this.status,
      taxPercentage: taxPercentage ?? this.taxPercentage,
    );
  }
}
