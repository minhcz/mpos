import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../database/app_database.dart';
import '../../../ui/screens/product/product_dialog.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late Future<List<Category>> _categoriesFuture;
  late Future<List<VatRate>> _vatRatesFuture;

  @override
  void initState() {
    super.initState();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _categoriesFuture = db.categoryDao.getAllCategories();
    _vatRatesFuture = db.vatRateDao.getAll();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final productDao = db.productDao;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final categories = await _categoriesFuture;
              final vatRates = await _vatRatesFuture;

              final result = await showDialog(
                context: context,
                builder: (_) => ProductDialog(
                  categories: categories,
                  vatRates: vatRates,
                ),
              );

              if (result == true) setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: productDao.watchAllWithCategoryAndTotalSold(db.categoryDao).first,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final products = snapshot.data!;
          if (products.isEmpty) return const Center(child: Text('Không có sản phẩm'));

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Tên')),
                DataColumn(label: Text('Mã vạch')),
                DataColumn(label: Text('Giá bán')),
                DataColumn(label: Text('Tồn kho')),
                DataColumn(label: Text('Đã bán')),
                DataColumn(label: Text('Nhóm hàng')),
                DataColumn(label: Text('VAT')),
                DataColumn(label: Text('')),
              ],
              rows: products.map((p) {
                return DataRow(cells: [
                  DataCell(Text('${p.product.id}')),
                  DataCell(Text(p.product.name)),
                  DataCell(Text(p.product.barcode)),
                  DataCell(Text('${p.product.price1.toStringAsFixed(0)}')),
                  DataCell(Text('${p.product.stockQuantity}')),
                  DataCell(Text('${p.totalSold}')),
                  DataCell(Text(p.category.name)),
                  DataCell(Text('${p.product.vat.toStringAsFixed(0)}%')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final categories = await _categoriesFuture;
                        final vatRates = await _vatRatesFuture;

                        final result = await showDialog(
                          context: context,
                          builder: (_) => ProductDialog(
                            product: p.product,
                            categories: categories,
                            vatRates: vatRates,
                          ),
                        );
                        if (result == true) setState(() {});
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}