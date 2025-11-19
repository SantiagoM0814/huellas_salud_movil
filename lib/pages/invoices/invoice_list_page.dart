import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/invoice.dart';
import '../../services/invoices_services.dart';
import './detail_invoice.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({Key? key}) : super(key: key);

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final InvoiceService _invoiceService = InvoiceService();
  late Future<List<Invoice>> _futureInvoices;
  List<Invoice> _allInvoices = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _futureInvoices = _invoiceService.getInvoices();
  }

  String _dateFormat(DateTime? date) {
    if (date == null) return "Sin fecha";
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

  String _money(num value) {
    return NumberFormat("#,###").format(value);
  }

  Color _statusColor(String status) {
    switch (status) {
      case "PAGADA":
        return Colors.green;
      case "ANULADA":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Genera número secuencial
  Map<Invoice, String> _buildInvoiceNumbers(List<Invoice> invoices) {
    invoices.sort((a, b) {
      if (a.date == null || b.date == null) return 0;
      return a.date!.compareTo(b.date!);
    });
    final map = <Invoice, String>{};
    for (int i = 0; i < invoices.length; i++) {
      map[invoices[i]] = (i + 1).toString().padLeft(3, '0');
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Facturas"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Invoice>>(
        future: _futureInvoices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          _allInvoices = snapshot.data ?? [];
          if (_allInvoices.isEmpty) {
            return const Center(child: Text("🚫 No hay facturas registradas"));
          }

          final invoiceNumbers = _buildInvoiceNumbers(_allInvoices);

          // Filtrar según búsqueda
          final filteredInvoices = _allInvoices.where((invoice) {
            final number = invoiceNumbers[invoice]!;
            final client = invoice.nameUserCreated ?? invoice.idClient;
            return client.toLowerCase().contains(_searchText.toLowerCase()) ||
                number.contains(_searchText);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Buscar por cliente o número de factura",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredInvoices.length,
                  itemBuilder: (_, index) {
                    final invoice = filteredInvoices[index];
                    final number = invoiceNumbers[invoice]!;

                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailInvoicePage(
                                  invoice: invoice,
                                  invoiceNumber: number,
                              )
                            ),
                          );
                        },
                        title: Text(
                          "Factura #$number",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Cliente: ${invoice.nameUserCreated ?? invoice.idClient}\n"
                          "Fecha: ${_dateFormat(invoice.date)}",
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${_money(invoice.total)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(invoice.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                invoice.status,
                                style: TextStyle(
                                  color: _statusColor(invoice.status),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
