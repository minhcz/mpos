// lib/database/tables/draft_invoice_items.dart
import 'package:drift/drift.dart';

class DraftInvoiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get draftInvoiceId => integer().customConstraint(
      'REFERENCES draft_invoices(id) ON DELETE CASCADE NOT NULL')();

  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();
  RealColumn get vat => real().withDefault(const Constant(0))();
}