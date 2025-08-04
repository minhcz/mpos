// ✅ invoice_table.dart
import 'package:flutter/material.dart';
import '../../../models/invoice/invoice_with_items.dart';
import 'invoice_detail_popup.dart';

class InvoiceTable extends StatelessWidget {
  final List<InvoiceWithItems> invoices;

  const InvoiceTable({super.key, required this.invoices});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 40,
        dataRowMaxHeight: 60,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Ngày')),
          DataColumn(label: Text('Tổng tiền')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Hành động')),
        ],
        rows: invoices.map((invoiceWithItems) {
          final invoice = invoiceWithItems.invoice;
          return DataRow(cells: [
            DataCell(Text(invoice.id.toString())),
            DataCell(Text(invoice.date.toString())),
            DataCell(Text('${invoice.total.toStringAsFixed(0)} đ')),
            DataCell(
              invoice.isRefunded
                  ? const Text('Đã hoàn', style: TextStyle(color: Colors.red))
                  : const Text('Hoàn tất'),
            ),
            DataCell(
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => InvoiceDetailPopup(invoiceWithItems: invoiceWithItems),
                  );
                },
                child: const Text('Xem'),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}