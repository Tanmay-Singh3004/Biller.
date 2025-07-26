import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/register.dart';
import '../models/customer.dart';
import '../models/item.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        UserSchema,
        RegisterSchema,
        CustomerSchema,
        ItemSchema,
        TransactionSchema,
        TransactionItemSchema,
      ],
      directory: dir.path,
    );
    return _isar!;
  }

  static Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }

  static Future<void> initialize() async {
    await instance; // This will initialize if not already done
  }
}
