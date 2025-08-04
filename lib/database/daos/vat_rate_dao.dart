import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/vat_rates.dart';

part 'vat_rate_dao.g.dart';

@DriftAccessor(tables: [VatRates])
class VatRateDao extends DatabaseAccessor<AppDatabase> with _$VatRateDaoMixin {
  VatRateDao(AppDatabase db) : super(db);

  Stream<List<VatRate>> watchAll() => select(vatRates).watch();

  Future<List<VatRate>> getAll() => select(vatRates).get();

  Future<void> insertOrUpdate(VatRatesCompanion entry) async {
    final existing = await (select(vatRates)
          ..where((t) => t.rate.equals(entry.rate.value)))
        .getSingleOrNull();

    if (existing != null) {
      await update(vatRates).replace(
        existing.copyWith(rate: entry.rate.value),
      );
    } else {
      await into(vatRates).insert(entry);
    }
  }

  Future<void> deleteRate(int id) async {
    await (delete(vatRates)..where((t) => t.id.equals(id))).go();
  }
}