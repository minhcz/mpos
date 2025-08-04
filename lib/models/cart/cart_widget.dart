import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart/cart_provider.dart';
import 'payment_dialog.dart';


class CartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: cart.items.map((item) => ListTile(
              title: Text(item.product.name),
              trailing: Text("x${item.quantity}"),
            )).toList(),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (_) => PaymentDialog(total: cart.total),
              );
              if (result == true) cart.clearCart();
            },
            child: Text("Thanh toán: ${cart.total.toStringAsFixed(0)} đ"),
          ),
        ),
      ],
    );
  }
}