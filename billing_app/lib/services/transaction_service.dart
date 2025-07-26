import 'package:isar/isar.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/item.dart';
import '../models/customer.dart';
import 'database_service.dart';
import 'item_service.dart';
import 'customer_service.dart';

class TransactionService {
  static Future<List<Transaction>> getTransactionsByRegisterId(int registerId, {int limit = 20, int offset = 0}) async {
    final isar = await DatabaseService.instance;
    return await isar.transactions
        .filter()
        .registerIdEqualTo(registerId)
        .sortByTransactionDateDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  static Future<Transaction> createTransaction({
    required int customerId,
    required int registerId,
    required List<TransactionItemData> items,
    double paymentReceived = 0.0,
  }) async {
    final isar = await DatabaseService.instance;
    
    double totalAmount = 0.0;
    for (var itemData in items) {
      totalAmount += itemData.quantity * itemData.pricePerUnit;
    }

    final transaction = Transaction()
      ..customerId = customerId
      ..registerId = registerId
      ..totalAmount = totalAmount
      ..paymentReceived = paymentReceived
      ..transactionDate = DateTime.now()
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.transactions.put(transaction);
      
      // Create transaction items
      for (var itemData in items) {
        final transactionItem = TransactionItem()
          ..transactionId = transaction.id
          ..itemId = itemData.itemId
          ..quantity = itemData.quantity
          ..pricePerUnit = itemData.pricePerUnit
          ..createdAt = DateTime.now();
        
        await isar.transactionItems.put(transactionItem);
        
        // Update stock
        await ItemService.decreaseStock(itemData.itemId, itemData.quantity);
      }
      
      // Update customer outstanding balance
      final customer = await isar.customers.get(customerId);
      if (customer != null) {
        customer.outstandingBalance += (totalAmount - paymentReceived);
        customer.updatedAt = DateTime.now();
        await isar.customers.put(customer);
      }
    });

    return transaction;
  }

  static Future<List<TransactionItem>> getTransactionItems(int transactionId) async {
    final isar = await DatabaseService.instance;
    return await isar.transactionItems
        .filter()
        .transactionIdEqualTo(transactionId)
        .findAll();
  }

  static Future<void> updatePayment(int transactionId, double newPaymentReceived) async {
    final isar = await DatabaseService.instance;
    
    final transaction = await isar.transactions.get(transactionId);
    if (transaction != null) {
      final oldPayment = transaction.paymentReceived;
      transaction.paymentReceived = newPaymentReceived;
      transaction.updatedAt = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.transactions.put(transaction);
        
        // Update customer outstanding balance
        final customer = await isar.customers.get(transaction.customerId);
        if (customer != null) {
          customer.outstandingBalance -= (newPaymentReceived - oldPayment);
          customer.updatedAt = DateTime.now();
          await isar.customers.put(customer);
        }
      });
    }
  }

  static Future<Transaction?> getTransactionById(int transactionId) async {
    final isar = await DatabaseService.instance;
    return await isar.transactions.get(transactionId);
  }

  static Future<void> deleteTransaction(int transactionId) async {
    final isar = await DatabaseService.instance;
    
    final transaction = await isar.transactions.get(transactionId);
    if (transaction == null) return;
    
    await isar.writeTxn(() async {
      // Get transaction items to restore stock
      final transactionItems = await isar.transactionItems
          .filter()
          .transactionIdEqualTo(transactionId)
          .findAll();
      
      for (var item in transactionItems) {
        // Restore stock
        final stockItem = await isar.items.get(item.itemId);
        if (stockItem != null) {
          stockItem.stockQuantity += item.quantity;
          stockItem.updatedAt = DateTime.now();
          await isar.items.put(stockItem);
        }
        
        // Delete transaction item
        await isar.transactionItems.delete(item.id);
      }
      
      // Update customer outstanding balance
      final customer = await isar.customers.get(transaction.customerId);
      if (customer != null) {
        customer.outstandingBalance -= transaction.outstandingAmount;
        customer.updatedAt = DateTime.now();
        await isar.customers.put(customer);
      }
      
      // Delete transaction
      await isar.transactions.delete(transactionId);
    });
  }
}

class TransactionItemData {
  final int itemId;
  final int quantity;
  final double pricePerUnit;

  TransactionItemData({
    required this.itemId,
    required this.quantity,
    required this.pricePerUnit,
  });
}
