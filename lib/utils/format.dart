// lib/utils/format.dart
import 'package:intl/intl.dart';

// Cấu hình mặc định, có thể thay đổi tại runtime
String currentLocale = 'cs_CZ';
String currencySymbol = 'Kč';

// Hàm format dùng trong toàn hệ thống (được gọi thông qua wrapper trong controller)
String formatCurrencyFromUtils(num amount) {
  final formatter = NumberFormat.currency(
    locale: currentLocale,
    symbol: currencySymbol,
    decimalDigits: 0, // Sửa thành 2 nếu cần hiển thị phần thập phân
  );
  return formatter.format(amount);
}

// Gọi khi người dùng chọn loại tiền tệ mới
void setCurrencyFormat({required String locale, required String symbol}) {
  currentLocale = locale;
  currencySymbol = symbol;
}