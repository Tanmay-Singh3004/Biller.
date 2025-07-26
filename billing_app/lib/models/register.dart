import 'package:isar/isar.dart';

part 'register.g.dart';

@collection
class Register {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  @Index()
  late int linkedUserId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
