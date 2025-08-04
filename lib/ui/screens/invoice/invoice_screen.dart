// invoice_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../database/app_database.dart';
import '../../../controllers/invoice_controller.dart';
import 'invoice_header.dart';
import 'invoice_table.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late final InvoiceController _controller;

  @override
  void initState() {
    super.initState();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _controller = InvoiceController(db); // Không cần loadInvoices()
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(title: const Text('Danh sách Hóa đơn')),
        body: Consumer<InvoiceController>(
          builder: (context, controller, _) => Column(
            children: [
              InvoiceHeader(controller: controller),
              Expanded(
                child: InvoiceTable(invoices: controller.filteredInvoices),
              ),
            ],
          ),
        ),
      ),
    );
  }
}