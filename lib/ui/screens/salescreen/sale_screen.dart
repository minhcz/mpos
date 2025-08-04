// lib/ui/screens/salescreen/sale_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../database/app_database.dart';
import '../../../controllers/sale_controller.dart';
import 'sale_cart_panel.dart';
import 'sale_numpad_panel.dart';
import 'sale_product_panel.dart';
import 'sale_category_bar.dart';

class SaleScreen extends StatelessWidget {
  const SaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDatabase>(
      builder: (context, db, _) {
        return ChangeNotifierProvider<SaleController>(
          create: (_) => SaleController(db),
          child: const SaleScreenBody(),
        );
      },
    );
  }
}

class SaleScreenBody extends StatefulWidget {
  const SaleScreenBody({super.key});

  @override
  State<SaleScreenBody> createState() => _SaleScreenBodyState();
}

class _SaleScreenBodyState extends State<SaleScreenBody> {
  final FocusNode barcodeFocusNode = FocusNode();

  @override
  void dispose() {
    barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);

    return Scaffold(
      body: Row(
        children: [
          // 🛒 Cột 1: Giỏ hàng + Numpad
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Giỏ hàng 60%
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => FocusScope.of(context).requestFocus(barcodeFocusNode),
                    child: const SaleCartPanel(),
                  ),
                ),
                const Divider(height: 1),
                // Numpad 40%
                Expanded(
                  flex: 2,
                  child: SaleNumpadPanel(barcodeFocusNode: barcodeFocusNode),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),

          // 🗂️ Cột 2: Danh sách nhóm hàng
          Consumer<SaleController>(
            builder: (context, controller, _) {
              return FutureBuilder(
                future: db.categoryDao.getAllCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      width: 150,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final categories = snapshot.data!;
                  return SizedBox(
                    width: 150,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => FocusScope.of(context).requestFocus(barcodeFocusNode),
                      child: SaleCategoryBar(categories: categories),
                    ),
                  );
                },
              );
            },
          ),
          const VerticalDivider(width: 1),

          // 🧾 Cột 3: Danh sách sản phẩm
          Expanded(
            flex: 5,
            child: Consumer2<AppDatabase, SaleController>(
              builder: (context, db, controller, _) {
                return FutureBuilder(
                  future: db.productDao.getAllProducts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = snapshot.data!
                        .where((p) =>
                            controller.selectedCategoryId == null ||
                            p.categoryId == controller.selectedCategoryId)
                        .toList();

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => FocusScope.of(context).requestFocus(barcodeFocusNode),
                      child: SaleProductPanel(
                        products: products,
                        barcodeFocusNode: barcodeFocusNode,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}