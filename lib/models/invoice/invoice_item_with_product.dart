// ✅ invoice_item_with_product.dart
import '../../database/app_database.dart';

/// DTO kết hợp giữa một dòng hàng và thông tin sản phẩm tương ứng
class InvoiceItemWithProduct {
  final InvoiceItem invoiceItem;
  final Product product;

  InvoiceItemWithProduct({
    required this.invoiceItem,
    required this.product,
  });
}