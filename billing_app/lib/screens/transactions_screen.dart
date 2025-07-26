import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/item_provider.dart';
import '../models/transaction.dart';
import '../models/customer.dart';
import '../models/item.dart';
import '../services/transaction_service.dart';
import '../services/pdf_service.dart';
import 'create_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading && transactionProvider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transactionProvider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _navigateToCreateTransaction(),
                    child: const Text('Create First Transaction'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              if (appProvider.currentRegister != null) {
                await transactionProvider.loadTransactions(
                  appProvider.currentRegister!.id,
                  refresh: true,
                );
              }
            },
            child: ListView.builder(
              itemCount: transactionProvider.transactions.length + 
                         (transactionProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == transactionProvider.transactions.length) {
                  // Load more indicator
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final appProvider = Provider.of<AppProvider>(context, listen: false);
                    if (appProvider.currentRegister != null) {
                      transactionProvider.loadTransactions(appProvider.currentRegister!.id);
                    }
                  });
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final transaction = transactionProvider.transactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTransaction(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: transaction.outstandingAmount > 0 
              ? Colors.orange[100] 
              : Colors.green[100],
          child: Icon(
            Icons.receipt,
            color: transaction.outstandingAmount > 0 
                ? Colors.orange[700] 
                : Colors.green[700],
          ),
        ),
        title: Text('Transaction #${transaction.id}'),
        subtitle: Text(
          '${transaction.transactionDate.toLocal().toString().split(' ')[0]} • ₹${transaction.totalAmount.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (transaction.outstandingAmount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PENDING',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PAID',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransactionDetail('Total Amount', '₹${transaction.totalAmount.toStringAsFixed(2)}'),
                _buildTransactionDetail('Payment Received', '₹${transaction.paymentReceived.toStringAsFixed(2)}'),
                if (transaction.outstandingAmount > 0)
                  _buildTransactionDetail(
                    'Outstanding', 
                    '₹${transaction.outstandingAmount.toStringAsFixed(2)}',
                    isHighlighted: true,
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _generatePDF(transaction),
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (transaction.outstandingAmount > 0)
                      ElevatedButton.icon(
                        onPressed: () => _recordPayment(transaction),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Pay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteTransaction(transaction),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetail(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.orange[700] : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.orange[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateTransactionScreen(),
      ),
    );
  }

  void _generatePDF(Transaction transaction) async {
    try {
      await PdfService.generateTransactionInvoice(transaction.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _recordPayment(Transaction transaction) {
    final _paymentController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final remainingAmount = transaction.outstandingAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment for Transaction #${transaction.id}'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outstanding Amount: ₹${remainingAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter payment amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > remainingAmount) {
                    return 'Payment cannot exceed outstanding amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final paymentAmount = double.parse(_paymentController.text);
                final newTotalPayment = transaction.paymentReceived + paymentAmount;
                
                final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
                await transactionProvider.updatePayment(transaction.id, newTotalPayment);
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment recorded successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete Transaction #${transaction.id}? This action cannot be undone and will restore stock quantities.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
              await transactionProvider.deleteTransaction(transaction.id);
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
