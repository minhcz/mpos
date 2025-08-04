import '../database/app_database.dart';

class DraftInvoiceWithItems {
  final DraftInvoice draft;
  final List<DraftInvoiceItem> items;

  DraftInvoiceWithItems({
    required this.draft,
    required this.items,
  });

  double get total {
    return items.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  DateTime get createdAt => draft.createdAt;

  String get displayName =>
      draft.name.isNotEmpty ? draft.name : 'Hóa đơn tạm #${draft.id}';
}    
