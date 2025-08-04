import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../../database/daos/invoice_dao.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = Provider.of<AppDatabase>(context, listen: false).invoiceDao;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê doanh thu'),
      ),
      body: FutureBuilder<List<InvoiceDetail>>(
        future: dao.getInvoiceWithItemsFull(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final details = snapshot.data ?? [];

          if (details.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu.'));
          }

          // Nhóm các InvoiceDetail theo invoice.id (nếu có)
          final groupedByInvoice = <int, List<InvoiceDetail>>{};
          for (var detail in details) {
            final invoice = detail.invoice;
            if (invoice == null) continue;

            final invoiceId = invoice.id;
            groupedByInvoice.putIfAbsent(invoiceId, () => []).add(detail);
          }

          return ListView.builder(
            itemCount: groupedByInvoice.length,
            itemBuilder: (context, index) {
              final invoiceId = groupedByInvoice.keys.elementAt(index);
              final items = groupedByInvoice[invoiceId]!;
              final invoice = items.first.invoice;

              if (invoice == null) {
                return const ListTile(title: Text('Hóa đơn không xác định'));
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(
                    'Hóa đơn #${invoice.id} - ${DateFormat('dd/MM/yyyy – HH:mm').format(invoice.date)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(invoice.total)}',
                  ),
                  children: items.map((item) {
                    final productName = item.product?.name ?? 'Không rõ sản phẩm';

                    return ListTile(
                      title: Text(productName),
                      subtitle: Text(
                        'SL: ${item.invoiceItem.quantity} × '
                        '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(item.invoiceItem.price)}',
                      ),
                      trailing: Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(
                          item.invoiceItem.quantity * item.invoiceItem.price,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}