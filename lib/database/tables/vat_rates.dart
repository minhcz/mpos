import 'package:drift/drift.dart';

class VatRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get rate => real()(); // phần trăm, ví dụ: 10.0, 21.0
}