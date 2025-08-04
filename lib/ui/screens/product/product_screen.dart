import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;

  Product(this.name, this.price);
}

class ProductScreen extends StatelessWidget {
  final List<Product> products = [
    Product('Cà phê', 25000),
    Product('Trà sữa', 30000),
    Product('Bánh mì', 20000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sản phẩm')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3 / 2,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã chọn ${product.name}')),
              );
            },
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(product.name, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('${product.price.toStringAsFixed(0)} đ'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}