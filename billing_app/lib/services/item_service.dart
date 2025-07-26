import 'package:isar/isar.dart';
import '../models/item.dart';
import 'database_service.dart';

class ItemService {
  static Future<List<Item>> getItemsByRegisterId(int registerId, {int limit = 20, int offset = 0}) async {
    final isar = await DatabaseService.instance;
    return await isar.items
        .filter()
        .linkedRegisterIdEqualTo(registerId)
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  static Future<List<Item>> searchItems(int registerId, String query, {int limit = 20}) async {
    final isar = await DatabaseService.instance;
    return await isar.items
        .filter()
        .linkedRegisterIdEqualTo(registerId)
        .and()
        .nameContains(query, caseSensitive: false)
        .limit(limit)
        .findAll();
  }

  static Future<Item> createItem({
    required String name,
    required int registerId,
    String? description,
    int stockQuantity = 0,
    double unitPrice = 0.0,
  }) async {
    final isar = await DatabaseService.instance;
    
    final item = Item()
      ..name = name
      ..description = description
      ..stockQuantity = stockQuantity
      ..unitPrice = unitPrice
      ..linkedRegisterId = registerId
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.items.put(item);
    });

    return item;
  }

  static Future<void> updateItem(Item item) async {
    final isar = await DatabaseService.instance;
    item.updatedAt = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.items.put(item);
    });
  }

  static Future<void> deleteItem(int itemId) async {
    final isar = await DatabaseService.instance;
    
    await isar.writeTxn(() async {
      await isar.items.delete(itemId);
    });
  }

  static Future<Item?> getItemById(int itemId) async {
    final isar = await DatabaseService.instance;
    return await isar.items.get(itemId);
  }

  static Future<void> updateStock(int itemId, int newQuantity) async {
    final isar = await DatabaseService.instance;
    
    final item = await isar.items.get(itemId);
    if (item != null) {
      item.stockQuantity = newQuantity;
      item.updatedAt = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.items.put(item);
      });
    }
  }

  static Future<void> decreaseStock(int itemId, int quantity) async {
    final isar = await DatabaseService.instance;
    
    final item = await isar.items.get(itemId);
    if (item != null) {
      item.stockQuantity = (item.stockQuantity - quantity).clamp(0, double.infinity).toInt();
      item.updatedAt = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.items.put(item);
      });
    }
  }
}
