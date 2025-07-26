import 'package:isar/isar.dart';

part 'transaction_item.g.dart';

@collection
class TransactionItem {
  Id id = Isar.autoIncrement;

  @Index()
  late int transactionId;

  @Index()
  late int itemId;

  int quantity = 1;

  double pricePerUnit = 0.0;

  double get totalPrice => quantity * pricePerUnit;

  DateTime createdAt = DateTime.now();
}
