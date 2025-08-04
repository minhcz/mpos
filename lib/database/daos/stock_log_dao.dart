import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart'; // Đảm bảo có export StockLogs ở đây

part 'stock_log_dao.g.dart';

@DriftAccessor(tables: [StockLogs])
class StockLogDao extends DatabaseAccessor<AppDatabase>
    with _$StockLogDaoMixin {
  StockLogDao(AppDatabase db) : super(db);

  Future<int> insertLog(StockLogsCompanion log) {
    return into(stockLogs).insert(log);
  }

  Future<List<StockLog>> getLogsForProduct(int productId) {
    return (select(stockLogs)
          ..where((tbl) => tbl.productId.equals(productId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  Stream<List<StockLog>> watchAllLogs() {
    return (select(stockLogs)..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])).watch();
  }
}