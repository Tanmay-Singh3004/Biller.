import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/customer.dart';
import '../models/item.dart';
import '../models/register.dart';
import 'database_service.dart';

class PdfService {
  static Future<void> generateAndShareInvoice({
    required Transaction transaction,
    required Customer customer,
    required Register register,
    required List<TransactionItem> transactionItems,
    required List<Item> items,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      register.name,
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.blue600,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Transaction and Customer Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(customer.name),
                      if (customer.email != null) pw.Text(customer.email!),
                      if (customer.phone != null) pw.Text(customer.phone!),
                      if (customer.address != null) pw.Text(customer.address!),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${transaction.id}'),
                      pw.Text('Date: ${dateFormat.format(transaction.transactionDate)}'),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Items Table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Item rows
                  ...transactionItems.map((transactionItem) {
                    final item = items.firstWhere((i) => i.id == transactionItem.itemId);
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${transactionItem.quantity}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('₹${transactionItem.pricePerUnit.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('₹${transactionItem.totalPrice.toStringAsFixed(2)}'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Totals
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Amount:'),
                          pw.Text('₹${transaction.totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Payment Received:'),
                          pw.Text('₹${transaction.paymentReceived.toStringAsFixed(2)}'),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Outstanding:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('₹${transaction.outstandingAmount.toStringAsFixed(2)}', 
                                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${transaction.id}_${customer.name.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> generateTransactionInvoice(int transactionId) async {
    final isar = await DatabaseService.instance;
    
    final transaction = await isar.transactions.get(transactionId);
    if (transaction == null) return;
    
    final customer = await isar.customers.get(transaction.customerId);
    if (customer == null) return;
    
    final register = await isar.registers.get(transaction.registerId);
    if (register == null) return;
    
    final transactionItems = await isar.transactionItems
        .filter()
        .transactionIdEqualTo(transactionId)
        .findAll();
    
    final items = <Item>[];
    for (var transactionItem in transactionItems) {
      final item = await isar.items.get(transactionItem.itemId);
      if (item != null) {
        items.add(item);
      }
    }
    
    await generateAndShareInvoice(
      transaction: transaction,
      customer: customer,
      register: register,
      transactionItems: transactionItems,
      items: items,
    );
  }
}
