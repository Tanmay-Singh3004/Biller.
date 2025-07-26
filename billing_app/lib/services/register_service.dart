import 'package:isar/isar.dart';
import '../models/register.dart';
import 'database_service.dart';

class RegisterService {
  static Future<List<Register>> getRegistersByUserId(int userId) async {
    final isar = await DatabaseService.instance;
    return await isar.registers
        .filter()
        .linkedUserIdEqualTo(userId)
        .findAll();
  }

  static Future<Register> createRegister(String name, int userId) async {
    final isar = await DatabaseService.instance;
    
    final register = Register()
      ..name = name
      ..linkedUserId = userId
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.registers.put(register);
    });

    return register;
  }

  static Future<void> updateRegister(Register register) async {
    final isar = await DatabaseService.instance;
    register.updatedAt = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.registers.put(register);
    });
  }

  static Future<void> deleteRegister(int registerId) async {
    final isar = await DatabaseService.instance;
    
    await isar.writeTxn(() async {
      await isar.registers.delete(registerId);
    });
  }

  static Future<Register?> getRegisterById(int registerId) async {
    final isar = await DatabaseService.instance;
    return await isar.registers.get(registerId);
  }
}
