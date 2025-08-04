// ✅ invoice_with_items.dart
import '../../database/app_database.dart';
import 'invoice_item_with_product.dart';

/// DTO đại diện cho một hóa đơn và danh sách sản phẩm tương ứng
class InvoiceWithItems {
  final Invoice invoice;
  final List<InvoiceItemWithProduct> items;

  InvoiceWithItems({
    required this.invoice,
    required this.items,
  });
}