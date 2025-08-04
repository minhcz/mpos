// invoice_controller.dart
import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/invoice/invoice_with_items.dart';

class InvoiceController extends ChangeNotifier {
  final AppDatabase db;

  List<InvoiceWithItems> _invoices = [];
  List<InvoiceWithItems> get invoices => _invoices;

  String _searchKeyword = '';
  String get searchKeyword => _searchKeyword;

  InvoiceController(this.db) {
    _watchInvoices();
  }

  void _watchInvoices() {
    db.invoiceDao.watchAllInvoicesWithDetails().listen((data) {
      _invoices = data;
      notifyListeners();
    });
  }

  void updateSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  List<InvoiceWithItems> get filteredInvoices {
    if (_searchKeyword.isEmpty) return _invoices;
    return _invoices.where((invoice) {
      final inv = invoice.invoice;
      return inv.id.toString().contains(_searchKeyword) ||
             inv.total.toString().contains(_searchKeyword);
    }).toList();
  }
}