// lib/database/tables/invoices.dart

import 'package:drift/drift.dart';

class Invoices extends Table {
  /// Mã hóa đơn tự động tăng
  IntColumn get id => integer().autoIncrement()();

  /// Ngày giờ tạo hóa đơn — bắt buộc, không được null
  DateTimeColumn get date => dateTime()();

  /// Tổng tiền — mặc định 0.0
  RealColumn get total => real().withDefault(const Constant(0.0))();

  /// Đã hoàn tiền hay chưa — mặc định false
  BoolColumn get isRefunded => boolean().withDefault(const Constant(false))();

  /// Phương thức thanh toán — ví dụ: 'Tiền mặt', 'Thẻ', 'Stravenky'
  /// Không để trống, giới hạn độ dài tối đa 50 ký tự
  TextColumn get paymentMethod =>
      text().withLength(min: 1, max: 50).withDefault(const Constant('Tiền mặt'))();
}