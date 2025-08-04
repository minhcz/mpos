import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Khai báo rõ là NOT NULL + UNIQUE
  TextColumn get username =>
      text().withLength(min: 4, max: 32).customConstraint('NOT NULL UNIQUE')();

  TextColumn get password => text().withLength(min: 4, max: 64).withDefault(Constant(''))();
  TextColumn get role => text().withLength(min: 1, max: 32).withDefault(Constant('staff'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}