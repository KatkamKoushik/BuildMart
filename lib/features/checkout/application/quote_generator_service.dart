import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../cart/data/cart_item_model.dart';
import '../../../models/user_model.dart';

class QuoteGeneratorService {
  static Future<Uint8List> generateQuote({
    required UserModel? user,
    required List<CartItemModel> items,
    required double subtotal,
    required double gst,
    required double total,
    required double discount,
  }) async {
    final pdf = pw.Document();
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs.');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            if (user != null) _buildCustomerInfo(user),
            pw.SizedBox(height: 30),
            _buildItemsTable(items, formatCurrency),
            pw.SizedBox(height: 20),
            _buildSummary(subtotal, gst, discount, total, formatCurrency),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('BuildMart Quotation',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.SizedBox(height: 8),
        pw.Text('Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}'),
        pw.Text('Valid until: ${DateFormat('dd MMM yyyy').format(DateTime.now().add(const Duration(days: 7)))}'),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(UserModel user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Prepared For:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 4),
        pw.Text(user.name),
        pw.Text(user.email),
        pw.Text(user.phone),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<CartItemModel> items, NumberFormat formatter) {
    return pw.TableHelper.fromTextArray(
      headers: ['S.No', 'Product', 'Qty', 'Unit Price', 'Amount'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      data: List<List<String>>.generate(
        items.length,
        (index) {
          final item = items[index];
          final amount = item.price * item.quantity;
          return [
            '${index + 1}',
            item.title,
            '${item.quantity}',
            formatter.format(item.price),
            formatter.format(amount),
          ];
        },
      ),
    );
  }

  static pw.Widget _buildSummary(double subtotal, double gst, double discount, double total, NumberFormat formatter) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _summaryRow('Subtotal:', formatter.format(subtotal)),
          if (discount > 0) _summaryRow('Discount:', '-${formatter.format(discount)}', color: PdfColors.green700),
          _summaryRow('GST (18%):', formatter.format(gst)),
          pw.Divider(),
          _summaryRow('Total Estimate:', formatter.format(total), isTotal: true),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value, {bool isTotal = false, PdfColor? color}) {
    return pw.Container(
      width: 200,
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('Thank you for your business!', style: const pw.TextStyle(fontSize: 12)),
        pw.Text('For queries, contact support@buildmart.com', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }
}
