// lib/ui/screens/invoice/refund_popup.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/refund_controller.dart';
import '../../../database/app_database.dart';
import '../../../models/invoice/invoice_with_items.dart';

class RefundPopup extends StatelessWidget {
  final InvoiceWithItems invoiceWithItems;

  const RefundPopup({Key? key, required this.invoiceWithItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) {
        final controller = RefundController(db);
        controller.setInvoiceData(invoiceWithItems);
        return controller;
      },
      child: const _RefundContent(),
    );
  }
}

class _RefundContent extends StatelessWidget {
  const _RefundContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RefundController>(
      builder: (context, controller, _) {
        return AlertDialog(
          title: const Text('Hoàn trả hóa đơn'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Chọn sản phẩm cần hoàn trả:'),
                const SizedBox(height: 12),
                ...controller.buildRefundFields(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: controller.isProcessing
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: controller.isProcessing || controller.refundSelected.isEmpty
                  ? null
                  : () async {
                      controller.isProcessing = true;
                      await controller.refundSelectedItems();
                      controller.isProcessing = false;
                      Navigator.of(context).pop();
                    },
              child: controller.isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Hoàn trả'),
            ),
          ],
        );
      },
    );
  }
}