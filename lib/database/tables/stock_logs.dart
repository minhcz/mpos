// lib/database/tables/stock_logs.dart

import 'package:drift/drift.dart';
import 'products.dart';

class StockLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get productId => integer().references(Products, #id)();

  IntColumn get quantityChange => integer()(); // Thay đổi tồn kho (âm/dương)

  TextColumn get reason => text()(); // Ví dụ: 'refund', 'sale', 'manual_adjustment', 'import', ...

  TextColumn get reference => text()(); // Mã hóa đơn hoặc ghi chú (BẮT BUỘC)

  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
}
