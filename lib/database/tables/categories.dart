// lib/database/tables/categories.dart

import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get parentId => integer().nullable()();
  IntColumn get vat => integer().withDefault(const Constant(21))();
  TextColumn get buttonColor => text().nullable()(); // Thêm màu nút (hex)
}