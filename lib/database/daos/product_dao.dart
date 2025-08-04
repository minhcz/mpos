import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import '../app_database.dart';
import '../tables/products.dart';
import '../tables/invoice_items.dart';
import '../tables/refunds.dart';
import '../tables/stock_logs.dart';
import '../daos/category_dao.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products, InvoiceItems, Refunds, StockLogs])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(AppDatabase db) : super(db);

  Future<Product?> getProductById(int id) {
    return (select(products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<Product?> getProductByBarcode(String barcode) {
    return (select(products)..where((tbl) => tbl.barcode.equals(barcode))).getSingleOrNull();
  }

  Future<void> updateProductStock(int id, int newStock) async {
    await (update(products)..where((tbl) => tbl.id.equals(id)))
        .write(ProductsCompanion(stockQuantity: Value(newStock)));
  }

  Future<List<Product>> getProductsByCategory(int categoryId) {
    return (select(products)..where((tbl) => tbl.categoryId.equals(categoryId))).get();
  }

  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

  Future<bool> updateProduct(Product product) {
    return update(products).replace(product);
  }

  Future<int> deleteProduct(int id) {
    return (delete(products)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Product>> getAllProducts() {
    return select(products).get();
  }

  Stream<List<Product>> watchAllProducts() {
    return select(products).watch();
  }

  Future<void> updateProductStockWithLog({
    required int productId,
    required int quantityChange,
    required String reason,
    required String reference,
  }) async {
    await transaction(() async {
      final product =
          await (select(products)..where((tbl) => tbl.id.equals(productId))).getSingle();

      final updatedStock = product.stockQuantity + quantityChange;

      await update(products).replace(
        product.copyWith(stockQuantity: updatedStock),
      );

      await into(stockLogs).insert(StockLogsCompanion.insert(
        productId: productId,
        quantityChange: quantityChange,
        reason: reason,
        reference: reference,
      ));
    });
  }

  /// ✅ Tính tổng đã bán - đã hoàn trả
  Future<Map<int, int>> computeTotalSold(
    List<InvoiceItem> invoiceItemsList,
    List<Refund> refundList,
  ) async {
    final Map<int, int> totals = {};

    for (final item in invoiceItemsList) {
      totals[item.productId] = (totals[item.productId] ?? 0) + item.quantity;
    }

    for (final refund in refundList) {
      totals[refund.productId] = (totals[refund.productId] ?? 0) - refund.quantity;
    }

    return totals;
  }

  /// ✅ Stream danh sách sản phẩm kèm danh mục và tổng bán
  Stream<List<ProductWithCategoryAndSold>> watchAllWithCategoryAndTotalSold(
      CategoryDao categoryDao) {
    return Rx.combineLatest3<List<Product>, List<InvoiceItem>, List<Refund>,
        Future<List<ProductWithCategoryAndSold>>>(
      select(products).watch(),
      select(invoiceItems).watch(),
      select(refunds).watch(),
      (productList, invoiceItemList, refundList) async {
        final categories = await categoryDao.getAllCategories();
        final soldMap = await computeTotalSold(invoiceItemList, refundList);

        return productList.map((p) {
          final category = categories.firstWhere(
            (c) => c.id == p.categoryId,
            orElse: () => Category(id: 0, name: 'Chưa phân loại', vat: 0),
          );
          final sold = soldMap[p.id] ?? 0;
          return ProductWithCategoryAndSold(
            product: p,
            category: category,
            totalSold: sold,
          );
        }).toList();
      },
    ).asyncMap((f) => f);
  }
}

class ProductWithCategoryAndSold {
  final Product product;
  final Category category;
  final int totalSold;

  ProductWithCategoryAndSold({
    required this.product,
    required this.category,
    required this.totalSold,
  });
}