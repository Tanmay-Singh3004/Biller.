import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../services/item_service.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  bool _isLoading = false;
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadItems(int registerId, {bool refresh = false}) async {
    if (refresh) {
      _items = [];
      _currentOffset = 0;
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    setLoading(true);
    try {
      final newItems = await ItemService.getItemsByRegisterId(
        registerId,
        limit: _limit,
        offset: _currentOffset,
      );

      if (newItems.length < _limit) {
        _hasMore = false;
      }

      _items.addAll(newItems);
      _currentOffset += newItems.length;
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> searchItems(int registerId, String query) async {
    setLoading(true);
    try {
      _items = await ItemService.searchItems(registerId, query);
      _hasMore = false; // Search results don't support pagination
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> addItem({
    required String name,
    required int registerId,
    String? description,
    int stockQuantity = 0,
    double unitPrice = 0.0,
  }) async {
    setLoading(true);
    try {
      final item = await ItemService.createItem(
        name: name,
        registerId: registerId,
        description: description,
        stockQuantity: stockQuantity,
        unitPrice: unitPrice,
      );
      _items.insert(0, item);
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateItem(Item item) async {
    setLoading(true);
    try {
      await ItemService.updateItem(item);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteItem(int itemId) async {
    setLoading(true);
    try {
      await ItemService.deleteItem(itemId);
      _items.removeWhere((i) => i.id == itemId);
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  void clearItems() {
    _items = [];
    _currentOffset = 0;
    _hasMore = true;
    notifyListeners();
  }
}
