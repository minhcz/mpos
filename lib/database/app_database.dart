import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Tables
import 'tables.dart';

// DAOs
import 'daos/product_dao.dart';
import 'daos/category_dao.dart';
import 'daos/invoice_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/stock_log_dao.dart';
import 'daos/vat_rate_dao.dart';
import 'daos/user_dao.dart';
import 'daos/draft_invoice_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Categories,
    Invoices,
    InvoiceItems,
    AppSettings,
    StockLogs,
    VatRates,
    Refunds,
    Users,
    DraftInvoices,
    DraftInvoiceItems,
  ],
  daos: [
    ProductDao,
    CategoryDao,
    InvoiceDao,
    SettingsDao,
    StockLogDao,
    VatRateDao,
    UserDao,
    DraftInvoiceDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          // VAT mặc định
          await batch((batch) {
            batch.insertAll(vatRates, [
              VatRatesCompanion(rate: Value(0)),
              VatRatesCompanion(rate: Value(10)),
              VatRatesCompanion(rate: Value(21)),
            ]);
          });
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}