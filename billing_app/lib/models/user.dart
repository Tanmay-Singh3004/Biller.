import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String email;

  late String passwordHash;

  @Index()
  bool googleAccountLinked = false;

  String? googleAccountId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
