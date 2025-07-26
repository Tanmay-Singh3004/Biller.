import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/customer.dart';
import '../models/item.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadTransactions(int registerId, {bool refresh = false}) async {
    if (refresh) {
      _transactions = [];
      _currentOffset = 0;
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    setLoading(true);
    try {
      final newTransactions = await TransactionService.getTransactionsByRegisterId(
        registerId,
        limit: _limit,
        offset: _currentOffset,
      );

      if (newTransactions.length < _limit) {
        _hasMore = false;
      }

      _transactions.addAll(newTransactions);
      _currentOffset += newTransactions.length;
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> createTransaction({
    required int customerId,
    required int registerId,
    required List<TransactionItemData> items,
    double paymentReceived = 0.0,
  }) async {
    setLoading(true);
    try {
      final transaction = await TransactionService.createTransaction(
        customerId: customerId,
        registerId: registerId,
        items: items,
        paymentReceived: paymentReceived,
      );
      _transactions.insert(0, transaction);
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> updatePayment(int transactionId, double newPaymentReceived) async {
    setLoading(true);
    try {
      await TransactionService.updatePayment(transactionId, newPaymentReceived);
      
      // Update local transaction
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        _transactions[index].paymentReceived = newPaymentReceived;
        _transactions[index].updatedAt = DateTime.now();
        notifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    setLoading(true);
    try {
      await TransactionService.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  void clearTransactions() {
    _transactions = [];
    _currentOffset = 0;
    _hasMore = true;
    notifyListeners();
  }
}
