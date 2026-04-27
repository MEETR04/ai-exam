class InvoiceItem {
  final String name;
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.name,
    this.description = '',
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    final hasName = json.containsKey('name');
    return InvoiceItem(
      name: (hasName ? json['name'] : json['description'] ?? '') as String,
      description: (hasName ? (json['description'] ?? '') : '') as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}
