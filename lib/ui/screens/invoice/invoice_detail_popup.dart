import 'package:flutter/material.dart';
import '../../../models/invoice/invoice_with_items.dart';
import 'refund_popup.dart';

class InvoiceDetailPopup extends StatelessWidget {
  final InvoiceWithItems invoiceWithItems;

  const InvoiceDetailPopup({super.key, required this.invoiceWithItems});

  @override
  Widget build(BuildContext context) {
    final invoice = invoiceWithItems.invoice;

    return AlertDialog(
      title: Text('Chi tiết hóa đơn #${invoice.id}'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ngày: ${invoice.date}'),
            Text('Tổng tiền: ${invoice.total.toStringAsFixed(0)} đ'),
            const SizedBox(height: 8),
            const Text('Danh sách sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
            ...invoiceWithItems.items.map((detail) {
              return ListTile(
                title: Text(detail.product.name),
                subtitle: Text('Số lượng: ${detail.invoiceItem.quantity}, Giá: ${detail.invoiceItem.price}'),
              );
            }),
          ],
        ),
      ),
      actions: [
        if (!invoice.isRefunded)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (_) => RefundPopup(invoiceWithItems: invoiceWithItems),
              );
            },
            child: const Text('Hoàn trả'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}