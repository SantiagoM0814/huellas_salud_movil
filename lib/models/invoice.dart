class Invoice {
  final String idInvoice;
  final DateTime? date;
  final String idClient;
  final String nameUserCreated;
  final num total;
  final String typeInvoice;
  final String status;
  final List<ItemInvoice> itemInvoice;

  Invoice({
    required this.idInvoice,
    required this.date,
    required this.idClient,
    required this.nameUserCreated,
    required this.total,
    required this.typeInvoice,
    required this.status,
    required this.itemInvoice,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final meta = json['meta'] ?? {};

    return Invoice(
      idInvoice: data['idInvoice'] ?? '',
      date: data['date'] != null ? DateTime.tryParse(data['date']) : null,
      idClient: data['idClient'] ?? '',
      nameUserCreated: meta['nameUserCreated'] ?? '',
      total: data['total'] ?? 0,
      typeInvoice: data['typeInvoice'] ?? '',
      status: data['status'] ?? '',
      itemInvoice: (data['itemInvoice'] as List<dynamic>? ?? [])
          .map((i) => ItemInvoice.fromJson(i))
          .toList(),
    );
  }
}

class ItemInvoice {
  final String? idProduct;
  final String? idService;
  final String? idPet;
  String? name; // ← Se rellena después
  final int quantity;
  final num unitPrice;
  final num subTotal;

  ItemInvoice({
    required this.idProduct,
    required this.idService,
    required this.idPet,
    this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
  });

  factory ItemInvoice.fromJson(Map<String, dynamic> json) {
    return ItemInvoice(
      idProduct: json['idProduct'],
      idService: json['idService'],
      idPet: json['idPet'],
      name: null, 
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unitPrice'] ?? 0,
      subTotal: json['subTotal'] ?? 0,
    );
  }
}
