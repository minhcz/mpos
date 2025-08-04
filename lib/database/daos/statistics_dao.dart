import '../../database/tables.dart';
import 'package:drift/drift.dart';
import '../../database/app_database.dart';

part 'statistics_dao.g.dart';

@DriftAccessor(tables: [Invoices, InvoiceItems, Products])
class StatisticsDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticsDaoMixin {
  StatisticsDao(AppDatabase db) : super(db);

  /// Tổng doanh thu giữa hai ngày
  Future<double> getRevenueBetween(DateTime start, DateTime end) async {
    final query = selectOnly(invoices)
      ..addColumns([invoices.total])
      ..where(invoices.date.isBetweenValues(start, end));

    final rows = await query.get();

    double total = 0.0;
    for (final row in rows) {
      final value = row.read(invoices.total);
      if (value != null) {
        total += value;
      }
    }
    return total;
  }

  /// Top sản phẩm bán chạy (tổng số lượng bán)
  Future<List<Map<String, dynamic>>> getTopSellingProducts(int limit) async {
    final totalQuantity = invoiceItems.quantity.sum();

    final query = select(invoiceItems).join([
      innerJoin(products, products.id.equalsExp(invoiceItems.productId)),
    ])
      ..addColumns([products.name, totalQuantity])
      ..groupBy([invoiceItems.productId])
      ..orderBy([
        OrderingTerm(expression: totalQuantity, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final result = await query.get();

    return result.map((row) {
      return {
        'productName': row.read(products.name),
        'quantity': row.read(totalQuantity) ?? 0,
      };
    }).toList();
  }

  /// Danh sách sản phẩm sắp hết hạn trong X ngày tới
  Future<List<Product>> getExpiringProductsWithin(int days) {
    final now = DateTime.now();
    final target = now.add(Duration(days: days));

    return (select(products)
          ..where((tbl) =>
              tbl.expiryDate.isNotNull() &
              tbl.expiryDate.isSmallerOrEqualValue(target)))
        .get();
  }
}