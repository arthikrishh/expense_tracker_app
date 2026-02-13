import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

class PdfExportService {
  static Future<void> generateExpenseReport(
    List<Expense> expenses,
    List<Category> categories,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Load custom fonts
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final fontBoldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      
      final ttf = pw.Font.ttf(fontData);
      final ttfBold = pw.Font.ttf(fontBoldData);

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttfBold,
        ),
      );

      // Calculate summary
      double totalAmount = expenses.fold(0, (sum, e) => sum + e.amount);
      double averageAmount = expenses.isNotEmpty ? totalAmount / expenses.length : 0;

      // Group by category
      Map<String, double> categoryTotals = {};
      Map<String, List<Expense>> categoryExpenses = {};
      
      for (var expense in expenses) {
        categoryTotals.update(
          expense.categoryId,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
        
        categoryExpenses.putIfAbsent(expense.categoryId, () => []);
        categoryExpenses[expense.categoryId]!.add(expense);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildHeader(context, ttfBold),
          footer: (context) => _buildFooter(context, ttf),
          build: (context) => [
            _buildTitle('Expense Report', ttfBold),
            pw.SizedBox(height: 20),
            
            // Date Range
            _buildInfoRow('Period:', 
              '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
              ttf, ttfBold),
            pw.SizedBox(height: 20),

            // Summary Section
            _buildSectionTitle('Summary', ttfBold),
            pw.SizedBox(height: 10),
            _buildSummaryCard(totalAmount, averageAmount, expenses.length, ttf, ttfBold),
            pw.SizedBox(height: 30),

            // Category Breakdown
            _buildSectionTitle('Category Breakdown', ttfBold),
            pw.SizedBox(height: 10),
            ..._buildCategoryBreakdown(categoryTotals, categories, totalAmount, ttf, ttfBold),
            pw.SizedBox(height: 30),

            // Detailed Transactions
            _buildSectionTitle('Transaction Details', ttfBold),
            pw.SizedBox(height: 10),
            ..._buildTransactionTable(expenses, categories, ttf, ttfBold),
          ],
        ),
      );

      // Save PDF with proper error handling
      await _savePdf(pdf);
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      rethrow;
    }
  }

  static pw.Widget _buildHeader(pw.Context context, pw.Font boldFont) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        children: [
          pw.Text(
            'Expense Tracker',
            style: pw.TextStyle(
              fontSize: 24,
              font: boldFont,
              color: PdfColors.blue,
            ),
          ),
          pw.Text(
            'Smart Expense Management',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
        style: pw.TextStyle(
          fontSize: 10,
          font: font,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  static pw.Widget _buildTitle(String title, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 20,
          font: boldFont,
          color: PdfColors.blue,
        ),
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          font: boldFont,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: boldFont,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(font: font),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCard(double total, double average, int count, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem('Total', '₹${total.toStringAsFixed(2)}', PdfColors.blue, font, boldFont),
          _buildSummaryItem('Average', '₹${average.toStringAsFixed(2)}', PdfColors.green, font, boldFont),
          _buildSummaryItem('Transactions', '$count', PdfColors.orange, font, boldFont),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            font: boldFont,
            color: color,
          ),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            font: font,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static List<pw.Widget> _buildCategoryBreakdown(
    Map<String, double> categoryTotals,
    List<Category> categories,
    double totalAmount,
    pw.Font font,
    pw.Font boldFont,
  ) {
    List<pw.Widget> widgets = [];

    for (var entry in categoryTotals.entries) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(
          id: 'unknown',
          name: 'Unknown',
          color: 0xFF808080,
          icon: '❓',
        ),
      );

      double percentage = (entry.value / totalAmount) * 100;

      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            children: [
              pw.Container(
                width: 30,
                child: pw.Text(
                  category.icon,
                  style: pw.TextStyle(font: font),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  category.name,
                  style: pw.TextStyle(font: font),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Text(
                  '₹${entry.value.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(font: font),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: pw.TextStyle(
                      font: boldFont,
                      color: PdfColors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  static List<pw.Widget> _buildTransactionTable(
    List<Expense> expenses,
    List<Category> categories,
    pw.Font font,
    pw.Font boldFont,
  ) {
    List<pw.Widget> widgets = [];

    // Table Header
    widgets.add(
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey300,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        ),
        child: pw.Row(
          children: [
            _buildTableCell('Date', flex: 2, font: boldFont),
            _buildTableCell('Title', flex: 3, font: boldFont),
            _buildTableCell('Category', flex: 2, font: boldFont),
            _buildTableCell('Amount', flex: 2, align: pw.TextAlign.right, font: boldFont),
          ],
        ),
      ),
    );

    // Table Rows
    for (var expense in expenses.take(20)) { // Limit to 20 rows for PDF
      final category = categories.firstWhere(
        (c) => c.id == expense.categoryId,
        orElse: () => Category(
          id: 'unknown',
          name: 'Unknown',
          color: 0xFF808080,
          icon: '❓',
        ),
      );

      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300),
            ),
          ),
          child: pw.Row(
            children: [
              _buildTableCell(
                DateFormat('MMM dd, yyyy').format(expense.date),
                flex: 2,
                font: font,
              ),
              _buildTableCell(expense.title, flex: 3, font: font),
              _buildTableCell('${category.icon} ${category.name}', flex: 2, font: font),
              _buildTableCell(
                '₹${expense.amount.toStringAsFixed(2)}',
                flex: 2,
                align: pw.TextAlign.right,
                font: boldFont,
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  static pw.Widget _buildTableCell(
    String text, {
    int flex = 1,
    pw.TextAlign align = pw.TextAlign.left,
    required pw.Font font,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: 10),
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf) async {
    try {
      // Get the application documents directory
      Directory? directory;
      
      // Try different platform directories
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access device storage');
      }

      // Create a meaningful filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'expense_report_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';
      
      // Write PDF file
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      debugPrint('PDF saved to: $filePath');

      // Open the file
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done) {
        debugPrint('Could not open file: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      rethrow;
    }
  }
}