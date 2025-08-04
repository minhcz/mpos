import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/tables/refunds.dart';
import '../../database/tables/invoices.dart';
import '../../database/tables/invoice_items.dart';
import '../../database/tables/products.dart';

part 'refund_dao.g.dart';

@DriftAccessor(tables: [Refunds, Invoices, InvoiceItems, Products])
class RefundDao extends DatabaseAccessor<AppDatabase> with _$RefundDaoMixin {
  final AppDatabase db;
  RefundDao(this.db) : super(db);

  /// Thêm hoàn trả mới
  Future<int> insertRefund(RefundsCompanion refund) {
    return into(refunds).insert(refund);
  }

  /// Trả lại một dòng hàng (theo số lượng cụ thể)
  Future<void> refundItem({
    required int invoiceId,
    required int invoiceItemId,
    required int productId,
    required int quantity,
    required double amount,
  }) async {
    await transaction(() async {
      // Ghi hoàn trả
      await insertRefund(RefundsCompanion(
        invoiceId: Value(invoiceId),
        invoiceItemId: Value(invoiceItemId),
        productId: Value(productId),
        quantity: Value(quantity),
        amount: Value(amount),
        date: Value(DateTime.now()),
      ));

      // Lấy sản phẩm hiện tại để cập nhật tồn kho
      final product = await (select(products)..where((p) => p.id.equals(productId))).getSingle();

      // Cập nhật tồn kho dựa trên stockQuantity
      final newStock = product.stockQuantity + quantity;

      // Cập nhật tồn kho trong bảng products
      await (update(products)..where((tbl) => tbl.id.equals(productId))).write(
        ProductsCompanion(stockQuantity: Value(newStock)),
      );
    });
  }

  /// Lấy danh sách hoàn trả theo hóa đơn
  Future<List<RefundDetail>> getRefundsByInvoice(int invoiceId) async {
    final query = select(refunds).join([
      leftOuterJoin(products, products.id.equalsExp(refunds.productId)),
      leftOuterJoin(invoiceItems, invoiceItems.id.equalsExp(refunds.invoiceItemId)),
    ])
      ..where(refunds.invoiceId.equals(invoiceId))
      ..orderBy([OrderingTerm.desc(refunds.date)]);

    final rows = await query.get();

    return rows.map((row) {
      return RefundDetail(
        refund: row.readTable(refunds),
        product: row.readTableOrNull(products),
        invoiceItem: row.readTableOrNull(invoiceItems),
      );
    }).toList();
  }

  /// Tổng tiền đã hoàn trả của một hóa đơn
  Future<double> getTotalRefundedAmount(int invoiceId) async {
    final expr = refunds.amount.sum();
    final query = selectOnly(refunds)
      ..addColumns([expr])
      ..where(refunds.invoiceId.equals(invoiceId));

    final result = await query.getSingleOrNull();
    return result?.read(expr) ?? 0.0;
  }
}

/// Dữ liệu hoàn trả + sản phẩm + dòng hàng
class RefundDetail {
  final Refund refund;
  final Product? product;
  final InvoiceItem? invoiceItem;

  RefundDetail({
    required this.refund,
    this.product,
    this.invoiceItem,
  });
}