import 'package:flutter/material.dart';
import '../../../database/app_database.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(product.name, style: const TextStyle(fontSize: 18)),
            Text('${product.price1.toStringAsFixed(2)} đ'),
          ],
        ),
      ),
    );
  }
}