// lib/controllers/refund_controller.dart

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/invoice/invoice_with_items.dart';

class RefundController extends ChangeNotifier {
  final AppDatabase db;
  late InvoiceWithItems invoiceData;

  final Set<int> refundSelected = {};
  final Map<int, TextEditingController> quantityControllers = {};

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  set isProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  RefundController(this.db);

  void setInvoiceData(InvoiceWithItems data) {
    invoiceData = data;
    for (final item in data.items) {
      quantityControllers[item.invoiceItem.id] =
          TextEditingController(text: item.invoiceItem.quantity.toString());
    }
  }

  List<Widget> buildRefundFields() {
    return invoiceData.items.map((item) {
      final id = item.invoiceItem.id;
      final controller = quantityControllers[id]!;

      return Row(
        children: [
          Checkbox(
            value: refundSelected.contains(id),
            onChanged: (val) {
              if (val == true) {
                refundSelected.add(id);
              } else {
                refundSelected.remove(id);
              }
              notifyListeners();
            },
          ),
          Expanded(
            child: Text('${item.product.name} (SL: ${item.invoiceItem.quantity})'),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(6),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Future<void> refundSelectedItems() async {
    for (final id in refundSelected) {
      final item = invoiceData.items.firstWhere((e) => e.invoiceItem.id == id);
      final quantity = int.tryParse(quantityControllers[id]!.text) ?? 0;

      final product = await db.productDao.getProductById(item.invoiceItem.productId);
      if (product != null) {
        final newStock = product.stockQuantity + quantity;
        await db.productDao.updateProductStock(product.id, newStock);
      }

      final amount = item.invoiceItem.price * quantity;

      await db.into(db.refunds).insert(RefundsCompanion(
        invoiceId: Value(item.invoiceItem.invoiceId),
        invoiceItemId: Value(id),
        productId: Value(item.invoiceItem.productId),
        quantity: Value(quantity),
        amount: Value(amount),
        date: Value(DateTime.now()),
      ));
    }

    // Nếu hoàn trả tất cả
    final allRefunded = refundSelected.length == invoiceData.items.length;
    if (allRefunded) {
      await db.invoiceDao.markInvoiceAsRefunded(invoiceData.invoice.id);
    }
  }

  @override
  void dispose() {
    for (final c in quantityControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}