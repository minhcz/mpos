import 'package:drift/drift.dart';
import 'invoices.dart';
import 'products.dart';

@DataClassName('InvoiceItem')
@TableIndex(name: 'idx_invoice_items_invoice_id', columns: {#invoiceId})
class InvoiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get invoiceId => integer().references(Invoices, #id)();

  IntColumn get productId => integer().references(Products, #id)();

  IntColumn get quantity => integer().withDefault(const Constant(1))();

  RealColumn get price => real()();

  RealColumn get total => real().withDefault(const Constant(0.0))();

  TextColumn get productName => text().nullable()();

  RealColumn get vat => real().nullable()();
}