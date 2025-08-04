// lib/database/tables/draft_invoices.dart
import 'package:drift/drift.dart';

class DraftInvoices extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withDefault(const Constant('Hóa đơn tạm'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
} 