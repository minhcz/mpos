// lib/ui/screens/salescreen/sale_cart_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sale_controller.dart';
import '../../../utils/format.dart';

class SaleCartPanel extends StatelessWidget {
  const SaleCartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SaleController>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Header
              Row(
                children: const [
                  Expanded(flex: 3, child: Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Giá', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('SL', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('VAT', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Tổng', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              const Divider(height: 1),

              // Danh sách sản phẩm trong giỏ hàng
              Expanded(
                child: controller.cart.isEmpty
                    ? const Center(child: Text('Chưa có sản phẩm'))
                    : ListView.separated(
                        itemCount: controller.cart.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = controller.cart.keys.elementAt(index);
                          final quantity = controller.cart[product]!;
                          final price = controller.usePrice2
                              ? (product.price2 ?? product.price1)
                              : product.price1;
                          final isSelected = controller.selectedCartProduct == product;

                          return InkWell(
                            onTap: () => controller.selectProductInCart(product),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade100 : null,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text(product.name, overflow: TextOverflow.ellipsis)),
                                  Expanded(flex: 2, child: Text(formatCurrencyFromUtils(price))),
                                  Expanded(child: Text('$quantity')),
                                  Expanded(child: Text('${product.vat.toStringAsFixed(0)}%')),
                                  Expanded(flex: 2, child: Text(formatCurrencyFromUtils(price * quantity))),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const Divider(height: 1),

              // Tổng tiền
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      formatCurrencyFromUtils(controller.total),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}