import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart'; // Đảm bảo dòng này đã được thêm
import '../../database/app_database.dart';
import '../../utils/format.dart';
import '../../models/draft_invoice_with_items.dart';

enum CheckoutResult { success, emptyCart, error }

class SaleController extends ChangeNotifier {
  final AppDatabase db;
  final Map<Product, int> _cart = {};
  int? selectedCategoryId;
  Product? selectedCartProduct;
  bool usePrice2 = false;

  String _numpadInput = ""; // Lưu trữ input từ numpad
  bool isEditingQuantity = false; // Trạng thái: true nếu đang nhập số lượng
  int? currentDraftId;

  SaleController(this.db);

  UnmodifiableMapView<Product, int> get cart => UnmodifiableMapView(_cart);

  double get total => _cart.entries.fold(0.0, (sum, entry) {
    final product = entry.key;
    final quantity = entry.value;
    final price = usePrice2 ? (product.price2 ?? product.price1) : product.price1;
    return sum + price * quantity;
  });

  // --- Numpad ---
  // Getter để truy cập giá trị numpadInput từ bên ngoài
  String get numpadInput => _numpadInput;

  // Cập nhật phương thức onNumpadInput để xử lý cả barcode và số lượng
  void onNumpadInput(String value, {bool isQuantityMode = false}) {
    if (isQuantityMode) {
      // Khi ở chế độ nhập số lượng, không giới hạn độ dài
      _numpadInput += value;
    } else {
      // Khi không ở chế độ số lượng (tức là nhập barcode), giới hạn 4 ký tự
      if (_numpadInput.length >= 4) return;
      _numpadInput += value;
    }
    notifyListeners();
  }

  // Cập nhật phương thức onBackspace
  void onBackspace({bool isQuantityMode = false}) {
    if (_numpadInput.isNotEmpty) {
      _numpadInput = _numpadInput.substring(0, _numpadInput.length - 1);
      notifyListeners();
    }
  }

  void clearNumpad() {
    _numpadInput = "";
    isEditingQuantity = false; // Luôn reset trạng thái khi xóa numpad
    notifyListeners();
  }

  // Bắt đầu chế độ chỉnh sửa số lượng
  void startEditQuantity() {
    // Khi người dùng nhấn nút "Số lượng", numpadInput sẽ chứa số lượng hiện tại của sản phẩm được chọn
    // nếu có, hoặc rỗng nếu không có.
    if (selectedCartProduct != null) {
      isEditingQuantity = true;
      _numpadInput = _cart[selectedCartProduct!].toString(); // Hiển thị số lượng hiện tại
      notifyListeners();
    }
  }

  // Phương thức MỚI để cập nhật số lượng sản phẩm đang chọn
  void updateSelectedProductQuantity(double newQuantity) {
    if (selectedCartProduct != null) {
      // Đảm bảo số lượng là số nguyên dương
      int qty = newQuantity.toInt();
      if (qty > 0) {
        updateQuantity(selectedCartProduct!, qty);
      } else {
        // Nếu số lượng <= 0, xóa sản phẩm khỏi giỏ hàng
        removeFromCart(selectedCartProduct!);
      }
    }
    clearNumpad(); // Xóa numpad input sau khi cập nhật
    notifyListeners();
  }

  // Phương thức này có thể không còn cần thiết hoặc được gọi từ updateSelectedProductQuantity
  // nếu bạn không có trường hợp sử dụng riêng biệt
  void applyNumpadToQuantity() {
    // Logic này hiện được tích hợp vào updateSelectedProductQuantity và nút "Số lượng"
    // nếu bạn vẫn muốn giữ nó, hãy cân nhắc lại luồng hoạt động
  }

  void commitQuantityEdit() {
    // Logic này hiện được tích hợp vào updateSelectedProductQuantity
  }

  void cancelCurrentSale() {
    clearCart();
    clearNumpad(); // Luôn xóa numpad khi hủy bán hàng
  }

  // --- Cart Logic ---
  void selectCategory(int? id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  void togglePriceMode() {
    usePrice2 = !usePrice2;
    notifyListeners();
  }

  void addToCart(Product product) {
    _cart.update(product, (qty) => qty + 1, ifAbsent: () => 1);
    selectedCartProduct = product;
    clearNumpad(); // Luôn xóa numpad và đặt lại trạng thái khi thêm sản phẩm
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.remove(product);
    if (selectedCartProduct == product) {
      selectedCartProduct = null;
    }
    clearNumpad(); // Luôn xóa numpad và đặt lại trạng thái khi xóa sản phẩm
    notifyListeners();
  }

  void removeSelectedProduct() {
    if (selectedCartProduct != null) {
      removeFromCart(selectedCartProduct!);
    }
  }

  void selectProductInCart(Product product) {
    selectedCartProduct = product;
    clearNumpad(); // Luôn xóa numpad và đặt lại trạng thái khi chọn sản phẩm
    notifyListeners();
  }

  void updateQuantity(Product product, int newQty) {
    if (newQty <= 0) {
      removeFromCart(product);
    } else {
      _cart[product] = newQty;
    }
    notifyListeners();
  }

  void clearCart({bool preserveDraftId = false}) {
    _cart.clear();
    selectedCartProduct = null;
    clearNumpad(); // Luôn xóa numpad khi xóa giỏ hàng
    if (!preserveDraftId) currentDraftId = null;
    notifyListeners();
  }

  // --- Barcode Input ---
  Future<void> processBarcodeInput(BuildContext context, String barcode) async {
    if (barcode.isEmpty) return;

    final product = await db.productDao.getProductByBarcode(barcode);
    if (product != null) {
      addToCart(product);
      clearNumpad(); // Xóa numpad input sau khi xử lý barcode
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Không tìm thấy sản phẩm')),
      );
      clearNumpad(); // Xóa numpad input ngay cả khi không tìm thấy sản phẩm
    }
  }

  // --- Placeholder cho Discount và Cash Drawer ---
  void startDiscount() {
    debugPrint("Bắt đầu giảm giá (chưa triển khai)");
    clearNumpad(); // Reset numpad khi bắt đầu giảm giá
  }

  void openCashDrawer() {
    debugPrint("Mở két tiền (chưa triển khai)");
    clearNumpad(); // Reset numpad khi mở két
  }

  // --- Checkout ---
  Future<CheckoutResult> checkout(BuildContext context) async {
    if (_cart.isEmpty) return CheckoutResult.emptyCart;

    try {
      final now = DateTime.now();
      final totalAmount = total;

      final invoiceId = await db.invoiceDao.insertInvoice(
        InvoicesCompanion(
          date: Value(now),
          total: Value(totalAmount),
        ),
      );

      for (final entry in _cart.entries) {
        final product = entry.key;
        final quantity = entry.value;
        final price = usePrice2 ? (product.price2 ?? product.price1) : product.price1;

        await db.invoiceDao.insertInvoiceItem(
          InvoiceItemsCompanion(
            invoiceId: Value(invoiceId),
            productId: Value(product.id),
            quantity: Value(quantity),
            price: Value(price),
            total: Value(price * quantity),
            productName: Value(product.name),
            vat: Value(product.vat),
          ),
        );

        await db.productDao.updateProductStockWithLog(
          productId: product.id,
          quantityChange: -quantity,
          reason: 'Bán hàng',
          reference: 'INV#$invoiceId',
        );
      }

      if (currentDraftId != null) {
        await db.draftInvoiceDao.deleteDraft(currentDraftId!);
        currentDraftId = null;
      }

      clearCart();
      clearNumpad(); // Luôn xóa numpad sau khi thanh toán
      return CheckoutResult.success;
    } catch (e) {
      debugPrint("Checkout error: $e");
      return CheckoutResult.error;
    }
  }

  // --- Draft Invoice ---
  Future<void> saveDraftInvoice() async {
    if (_cart.isEmpty) return;

    final now = DateTime.now();

    if (currentDraftId != null) {
      await db.draftInvoiceDao.deleteDraft(currentDraftId!);
    }

    final draftId = await db.draftInvoiceDao.insertDraftInvoice(
      DraftInvoicesCompanion(
        name: const Value(""),
        createdAt: Value(now),
      ),
    );

    // Dòng lỗi đã được sửa tại đây
    final draftName = "DRAFT#${DateFormat('yyyyMMdd').format(now)}-${draftId.toString().padLeft(4, '0')}";
    await db.draftInvoiceDao.updateDraftName(draftId, draftName);

    for (final entry in _cart.entries) {
      final product = entry.key;
      final quantity = entry.value;
      final price = usePrice2 ? (product.price2 ?? product.price1) : product.price1;

      await db.draftInvoiceDao.insertDraftItem(
        DraftInvoiceItemsCompanion(
          draftInvoiceId: Value(draftId),
          productId: Value(product.id),
          quantity: Value(quantity),
          price: Value(price),
          vat: Value(product.vat),
          productName: Value(product.name),
        ),
      );
    }

    currentDraftId = null;
    clearCart(preserveDraftId: false);
    clearNumpad(); // Luôn xóa numpad sau khi lưu tạm
  }

  Future<List<DraftInvoiceWithItems>> getAllDrafts() async {
    return db.draftInvoiceDao.getAllDraftsWithItems();
  }

  Future<void> deleteDraft(int draftId) async {
    await db.draftInvoiceDao.deleteDraft(draftId);
    if (currentDraftId == draftId) {
      currentDraftId = null;
    }
    clearNumpad(); // Luôn xóa numpad sau khi xóa hóa đơn nháp
    notifyListeners();
  }

  Future<void> loadDraftInvoice(DraftInvoiceWithItems draft) async {
    clearCart(preserveDraftId: true);

    for (final item in draft.items) {
      final product = await db.productDao.getProductById(item.productId);
      if (product != null) {
        _cart[product] = item.quantity;
      }
    }

    currentDraftId = draft.draft.id;
    clearNumpad(); // Luôn xóa numpad sau khi tải hóa đơn nháp
    notifyListeners();
  }

  // --- Xóa toàn bộ hóa đơn tạm trong ngày hôm nay ---
  Future<void> deleteAllDraftsInToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

    await db.draftInvoiceDao.deleteDraftsBetween(startOfDay, endOfDay);
    clearNumpad(); // Luôn xóa numpad sau khi xóa các hóa đơn nháp
    notifyListeners();
  }

  // --- Helper ---
  String formatCurrency(double amount) => formatCurrencyFromUtils(amount);

  // Sửa hàm formatDate để sử dụng DateFormat từ intl
  String formatDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }
}