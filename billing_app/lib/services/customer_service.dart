import 'package:isar/isar.dart';
import '../models/customer.dart';
import 'database_service.dart';

class CustomerService {
  static Future<List<Customer>> getCustomersByRegisterId(int registerId, {int limit = 20, int offset = 0}) async {
    final isar = await DatabaseService.instance;
    return await isar.customers
        .filter()
        .linkedRegisterIdEqualTo(registerId)
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  static Future<List<Customer>> searchCustomers(int registerId, String query, {int limit = 20}) async {
    final isar = await DatabaseService.instance;
    return await isar.customers
        .filter()
        .linkedRegisterIdEqualTo(registerId)
        .and()
        .nameContains(query, caseSensitive: false)
        .limit(limit)
        .findAll();
  }

  static Future<Customer> createCustomer({
    required String name,
    required int registerId,
    String? email,
    String? phone,
    String? address,
  }) async {
    final isar = await DatabaseService.instance;
    
    final customer = Customer()
      ..name = name
      ..email = email
      ..phone = phone
      ..address = address
      ..linkedRegisterId = registerId
      ..outstandingBalance = 0.0
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.customers.put(customer);
    });

    return customer;
  }

  static Future<void> updateCustomer(Customer customer) async {
    final isar = await DatabaseService.instance;
    customer.updatedAt = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.customers.put(customer);
    });
  }

  static Future<void> deleteCustomer(int customerId) async {
    final isar = await DatabaseService.instance;
    
    await isar.writeTxn(() async {
      await isar.customers.delete(customerId);
    });
  }

  static Future<Customer?> getCustomerById(int customerId) async {
    final isar = await DatabaseService.instance;
    return await isar.customers.get(customerId);
  }

  static Future<void> updateOutstandingBalance(int customerId, double newBalance) async {
    final isar = await DatabaseService.instance;
    
    final customer = await isar.customers.get(customerId);
    if (customer != null) {
      customer.outstandingBalance = newBalance;
      customer.updatedAt = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.customers.put(customer);
      });
    }
  }
}
