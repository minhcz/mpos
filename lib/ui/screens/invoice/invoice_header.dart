import 'package:flutter/material.dart';
import '../../../controllers/invoice_controller.dart';

class InvoiceHeader extends StatelessWidget {
  final InvoiceController controller;

  const InvoiceHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: controller.updateSearchKeyword,
        decoration: const InputDecoration(
          labelText: 'Tìm kiếm hóa đơn',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}