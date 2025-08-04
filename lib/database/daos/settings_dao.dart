// lib/database/daos/settings_dao.dart
import '../../database/tables.dart';
import 'package:drift/drift.dart';
import '../../database/app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(AppDatabase db) : super(db);

  Future<AppSetting?> getCurrentSettings() => select(appSettings).getSingleOrNull();

  Stream<AppSetting?> watchSettings() => select(appSettings).watchSingleOrNull();

  Future<void> insertOrUpdateSettings(AppSettingsCompanion entry) async {
    final current = await getCurrentSettings();
    if (current != null) {
      await (update(appSettings)..where((tbl) => tbl.id.equals(current.id))).write(entry);
    } else {
      await into(appSettings).insert(entry);
    }
  }
}