import 'package:flutter/material.dart';
import '../../../database/app_database.dart';
import 'product_card.dart';

class ProductGridWidget extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onTap;

  const ProductGridWidget({super.key, required this.products, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      children: products.map((p) => ProductCard(product: p, onTap: () => onTap(p))).toList(),
    );
  }
}