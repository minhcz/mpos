import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../database/app_database.dart';
import '../../../models/invoice/invoice_item_with_product.dart';

Future<void> printInvoice({
  required Invoice invoice,
  required List<InvoiceItemWithProduct> items,
}) async {
  final doc = pw.Document();

  // Load font hỗ trợ tiếng Việt
  final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text('DAŇOVÝ DOKLAD / HÓA ĐƠN BÁN HÀNG',
          style: pw.TextStyle(font: fontBold, fontSize: 22),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Datum vystavení: ${_formatCzDate(invoice.date)}', style: pw.TextStyle(font: fontRegular)),
        pw.SizedBox(height: 5),
        pw.Text('Číslo dokladu / Số hóa đơn: ${invoice.id}', style: pw.TextStyle(font: fontRegular)),

        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(font: fontBold),
          cellStyle: pw.TextStyle(font: fontRegular),
          headers: ['Položka', 'Množství', 'Cena/jed.', 'Celkem'],
          data: items.map((item) {
            final p = item.product;
            final i = item.invoiceItem;
            final total = i.price * i.quantity;
            return [
              p.name,
              i.quantity.toString(),
              '${i.price.toStringAsFixed(2)} Kč',
              '${total.toStringAsFixed(2)} Kč',
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Celková částka / Tổng cộng: ${invoice.total.toStringAsFixed(2)} Kč',
            style: pw.TextStyle(font: fontBold, fontSize: 16),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Děkujeme za váš nákup! / Xin cảm ơn quý khách!',
          style: pw.TextStyle(font: fontRegular),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => doc.save(),
  );
}

String _formatCzDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}