import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/invoice.dart';
import '../../services/invoices_services.dart';

class DetailInvoicePage extends StatefulWidget {
  final Invoice invoice;
  final String invoiceNumber;

  const DetailInvoicePage({
    super.key,
    required this.invoice,
    required this.invoiceNumber,
  });

  @override
  State<DetailInvoicePage> createState() => _DetailInvoicePageState();
}

class _DetailInvoicePageState extends State<DetailInvoicePage> {
  final InvoiceService productService = InvoiceService();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadItemNames();
  }

  Future<void> loadItemNames() async {
    for (var item in widget.invoice.itemInvoice) {
      if (item.idProduct != null) {
        item.name = await productService.getProductName(item.idProduct!);
      } else if (item.idService != null) {
        item.name = await productService.getServiceName(item.idService!);
      } else {
        item.name = "Producto/Servicio";
      }
    }
    setState(() => loading = false);
  }

  String _formatPrice(num value) {
    return NumberFormat('#,###').format(value);
  }

  String _dateFormat(DateTime? date) {
    if (date == null) return 'Sin fecha';
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Factura")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Factura #${widget.invoiceNumber}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildInfoRow('Cliente:', widget.invoice.nameUserCreated),
            _buildInfoRow('Fecha:', _dateFormat(widget.invoice.date)),

            const Divider(height: 30),
            const Text('Productos/Servicios:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...widget.invoice.itemInvoice.map(_buildItemRow).toList(),

            const Divider(height: 30),
            _buildTotalRow("TOTAL", widget.invoice.total),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildItemRow(ItemInvoice item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name ?? "Producto/Servicio",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${_formatPrice(item.unitPrice)}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, num value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          '\$${_formatPrice(value)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
