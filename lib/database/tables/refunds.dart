import 'package:drift/drift.dart';
import 'invoices.dart';
import 'invoice_items.dart';
import 'products.dart';

class Refunds extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get invoiceId => integer()
      .references(Invoices, #id, onDelete: KeyAction.cascade)();

  IntColumn get invoiceItemId => integer()
      .references(InvoiceItems, #id, onDelete: KeyAction.cascade)();

  IntColumn get productId => integer()
      .references(Products, #id, onDelete: KeyAction.cascade)();

  IntColumn get quantity => integer()
      .check(quantity.isBiggerThanValue(0))();

  RealColumn get amount => real()
      .check(amount.isBiggerOrEqualValue(0))();

  DateTimeColumn get date => dateTime()
      .withDefault(currentDateAndTime)();
}