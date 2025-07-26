import 'package:isar/isar.dart';

part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  String? description;

  int stockQuantity = 0;

  double unitPrice = 0.0;

  @Index()
  late int linkedRegisterId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
