// lib/ui/screens/salescreen/sale_product_panel.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sale_controller.dart';
import '../../../database/app_database.dart';

class SaleProductPanel extends StatelessWidget {
  final List<Product> products;
  final FocusNode barcodeFocusNode;

  const SaleProductPanel({
    super.key,
    required this.products,
    required this.barcodeFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SaleController>(context);
    final selectedCatId = controller.selectedCategoryId;

    final filtered = selectedCatId == null
        ? products
        : products.where((p) => p.categoryId == selectedCatId).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (_, index) {
        final product = filtered[index];
        final hasImage = (product.imagePath?.isNotEmpty ?? false) &&
            File(product.imagePath!).existsSync();

        return GestureDetector(
          onTap: () {
            controller.addToCart(product);
            FocusScope.of(context).requestFocus(barcodeFocusNode); // 🔄 Tự động focus lại
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: hasImage
                      ? DecorationImage(
                          image: FileImage(File(product.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: hasImage ? null : const Color(0xFFE3F2FD),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromARGB(60, 255, 255, 255),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.barcode,
                      style: const TextStyle(fontSize: 9),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      controller.formatCurrency(product.price1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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