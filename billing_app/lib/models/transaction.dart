import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime transactionDate = DateTime.now();

  @Index()
  late int customerId;

  @Index()
  late int registerId;

  double totalAmount = 0.0;

  double paymentReceived = 0.0;

  double get outstandingAmount => totalAmount - paymentReceived;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
