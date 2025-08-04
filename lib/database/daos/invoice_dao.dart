import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/tables/invoices.dart';
import '../../database/tables/invoice_items.dart';
import '../../database/tables/products.dart';
import '../../models/invoice/invoice_with_items.dart';
import '../../models/invoice/invoice_item_with_product.dart';

part 'invoice_dao.g.dart';

@DriftAccessor(tables: [Invoices, InvoiceItems, Products])
class InvoiceDao extends DatabaseAccessor<AppDatabase> with _$InvoiceDaoMixin {
  final AppDatabase db;
  InvoiceDao(this.db) : super(db);

  /// Thêm hóa đơn
  Future<int> insertInvoice(InvoicesCompanion invoice) {
    return into(invoices).insert(invoice);
  }

  /// Thêm dòng hàng
  Future<int> insertInvoiceItem(InvoiceItemsCompanion item) {
    return into(invoiceItems).insert(item);
  }

  /// Thêm hóa đơn và dòng hàng trong transaction
  Future<int> insertInvoiceWithItems(
    InvoicesCompanion invoice,
    List<InvoiceItemsCompanion> items,
  ) async {
    return transaction(() async {
      final invoiceId = await insertInvoice(invoice);
      for (final item in items) {
        final withInvoiceId = item.copyWith(invoiceId: Value(invoiceId));
        await insertInvoiceItem(withInvoiceId);
      }
      return invoiceId;
    });
  }

  /// Stream danh sách hóa đơn
  Stream<List<Invoice>> watchAllInvoices() {
    return (select(invoices)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .watch();
  }

  /// ✅ Stream toàn bộ hóa đơn cùng dòng hàng và sản phẩm (cập nhật động)
  Stream<List<InvoiceWithItems>> watchAllInvoicesWithDetails() {
    return watchAllInvoices().asyncMap((invoiceList) async {
      final List<InvoiceWithItems> result = [];

      for (final invoice in invoiceList) {
        final items = await (select(invoiceItems)..where((t) => t.invoiceId.equals(invoice.id))).get();

        final List<InvoiceItemWithProduct> itemsWithProduct = [];

        for (final item in items) {
          final product = await (select(products)..where((t) => t.id.equals(item.productId))).getSingleOrNull();
          if (product != null) {
            itemsWithProduct.add(InvoiceItemWithProduct(invoiceItem: item, product: product));
          }
        }

        result.add(InvoiceWithItems(invoice: invoice, items: itemsWithProduct));
      }

      return result;
    });
  }

  /// Lấy danh sách hóa đơn
  Future<List<Invoice>> getAllInvoices() {
    return (select(invoices)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  /// Lấy chi tiết dòng hàng của hóa đơn
  Future<List<InvoiceDetail>> getInvoiceWithDetails(int invoiceId) {
    final query = (select(invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).join([
      leftOuterJoin(products, products.id.equalsExp(invoiceItems.productId)),
    ]);

    return query.map((row) {
      return InvoiceDetail(
        invoiceItem: row.readTable(invoiceItems),
        product: row.readTableOrNull(products),
      );
    }).get();
  }

  /// Trả về toàn bộ dòng hàng + hóa đơn + sản phẩm (cho thống kê hoặc preview)
  Future<List<InvoiceDetail>> getInvoiceWithItemsFull() async {
    final query = select(invoiceItems).join([
      innerJoin(products, products.id.equalsExp(invoiceItems.productId)),
      innerJoin(invoices, invoices.id.equalsExp(invoiceItems.invoiceId)),
    ]);

    final rows = await query.get();

    return rows.map((row) {
      return InvoiceDetail(
        invoice: row.readTable(invoices),
        invoiceItem: row.readTable(invoiceItems),
        product: row.readTable(products),
      );
    }).toList();
  }

  /// Lọc hóa đơn theo khoảng thời gian và hình thức thanh toán
  Future<List<Invoice>> filterInvoices({
    DateTime? from,
    DateTime? to,
    String? paymentMethod,
  }) async {
    final query = select(invoices);

    if (from != null) {
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(from));
    }

    if (to != null) {
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(to));
    }

    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      query.where((tbl) => tbl.paymentMethod.equals(paymentMethod));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.get();
  }

  /// Xóa hóa đơn và dòng hàng liên quan
  Future<void> deleteInvoice(int invoiceId) async {
    await transaction(() async {
      await (delete(invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).go();
      await (delete(invoices)..where((t) => t.id.equals(invoiceId))).go();
    });
  }

  /// Lấy toàn bộ hóa đơn cùng dòng hàng và sản phẩm
  Future<List<InvoiceWithItems>> getAllInvoicesWithDetails() async {
    final invoiceList = await getAllInvoices();
    final List<InvoiceWithItems> result = [];

    for (final invoice in invoiceList) {
      final items = await (select(invoiceItems)..where((t) => t.invoiceId.equals(invoice.id))).get();

      final List<InvoiceItemWithProduct> itemsWithProduct = [];

      for (final item in items) {
        final product = await (select(products)..where((t) => t.id.equals(item.productId))).getSingle();
        itemsWithProduct.add(InvoiceItemWithProduct(invoiceItem: item, product: product));
      }

      result.add(InvoiceWithItems(invoice: invoice, items: itemsWithProduct));
    }

    return result;
  }

  /// Đánh dấu hóa đơn đã hoàn tiền
  Future<void> markInvoiceAsRefunded(int invoiceId) {
    return (update(invoices)..where((tbl) => tbl.id.equals(invoiceId)))
        .write(InvoicesCompanion(isRefunded: Value(true)));
  }
}

/// Dữ liệu hóa đơn + sản phẩm + dòng hàng (dùng cho preview hoặc chi tiết)
class InvoiceDetail {
  final Invoice? invoice;
  final InvoiceItem invoiceItem;
  final Product? product;

  InvoiceDetail({
    this.invoice,
    required this.invoiceItem,
    this.product,
  });
}