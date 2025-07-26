import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadCustomers(int registerId, {bool refresh = false}) async {
    if (refresh) {
      _customers = [];
      _currentOffset = 0;
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    setLoading(true);
    try {
      final newCustomers = await CustomerService.getCustomersByRegisterId(
        registerId,
        limit: _limit,
        offset: _currentOffset,
      );

      if (newCustomers.length < _limit) {
        _hasMore = false;
      }

      _customers.addAll(newCustomers);
      _currentOffset += newCustomers.length;
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> searchCustomers(int registerId, String query) async {
    setLoading(true);
    try {
      _customers = await CustomerService.searchCustomers(registerId, query);
      _hasMore = false; // Search results don't support pagination
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> addCustomer({
    required String name,
    required int registerId,
    String? email,
    String? phone,
    String? address,
  }) async {
    setLoading(true);
    try {
      final customer = await CustomerService.createCustomer(
        name: name,
        registerId: registerId,
        email: email,
        phone: phone,
        address: address,
      );
      _customers.insert(0, customer);
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    setLoading(true);
    try {
      await CustomerService.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
        notifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    setLoading(true);
    try {
      await CustomerService.deleteCustomer(customerId);
      _customers.removeWhere((c) => c.id == customerId);
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  void clearCustomers() {
    _customers = [];
    _currentOffset = 0;
    _hasMore = true;
    notifyListeners();
  }
}
