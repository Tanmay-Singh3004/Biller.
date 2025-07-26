import 'package:isar/isar.dart';

part 'customer.g.dart';

@collection
class Customer {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  String? email;

  String? phone;

  String? address;

  @Index()
  late int linkedRegisterId;

  double outstandingBalance = 0.0;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
