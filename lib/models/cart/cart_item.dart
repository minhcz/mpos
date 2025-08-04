import '../../database/app_database.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Tổng tiền của dòng sản phẩm này (dùng khi hiển thị hoặc tính tổng giỏ hàng)
  double get totalPrice => product.price1 * quantity;
}