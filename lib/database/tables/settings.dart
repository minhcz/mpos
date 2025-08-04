// lib/database/tables/settings.dart
import 'package:drift/drift.dart';

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get currency => text().withDefault(const Constant('czk'))();
  RealColumn get eurToCzk => real().nullable()();
  RealColumn get usdToCzk => real().nullable()();
  TextColumn get language => text().withDefault(const Constant('cs'))();
}