import 'package:drift/drift.dart';
import 'categories.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Tên sản phẩm (bắt buộc)
  TextColumn get name => text()();

  /// Giá bán chính
  RealColumn get price1 => real()();

  /// Giá bán phụ (nếu có)
  RealColumn get price2 => real().nullable()();

  /// Giá nhập (có thể null)
  RealColumn get purchasePrice => real().nullable()();

  /// Số lượng tồn kho (mặc định = 0)
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();

  /// Mã vạch (barcode), bắt buộc và duy nhất
  TextColumn get barcode =>
      text().withLength(min: 1).customConstraint('UNIQUE NOT NULL')();

  /// ID danh mục (category), có thể null
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  /// VAT (%) - mặc định là 0.0
  RealColumn get vat => real().withDefault(const Constant(0.0))();

  /// Đường dẫn ảnh sản phẩm (có thể null)
  TextColumn get imagePath => text().nullable()();

  /// Hạn sử dụng sản phẩm (nullable)
  DateTimeColumn get expiryDate => dateTime().nullable()();

  /// Màu nút hiển thị sản phẩm dạng mã hex, ví dụ "#FF5733" (nullable)
  TextColumn get buttonColor => text().nullable()();
}