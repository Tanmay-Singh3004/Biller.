import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:isar/isar.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static Future<User?> signUp(String email, String password) async {
    final isar = await DatabaseService.instance;
    
    // Check if user already exists
    final existingUser = await isar.users
        .filter()
        .emailEqualTo(email)
        .findFirst();
    
    if (existingUser != null) {
      throw Exception('User already exists with this email');
    }

    final user = User()
      ..email = email
      ..passwordHash = _hashPassword(password)
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.users.put(user);
    });

    return user;
  }

  static Future<User?> signIn(String email, String password) async {
    final isar = await DatabaseService.instance;
    
    final user = await isar.users
        .filter()
        .emailEqualTo(email)
        .and()
        .passwordHashEqualTo(_hashPassword(password))
        .findFirst();

    return user;
  }

  static Future<void> linkGoogleAccount(int userId, String googleAccountId) async {
    final isar = await DatabaseService.instance;
    
    final user = await isar.users.get(userId);
    if (user != null) {
      user.googleAccountLinked = true;
      user.googleAccountId = googleAccountId;
      user.updatedAt = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.users.put(user);
      });
    }
  }

  static Future<void> unlinkGoogleAccount(int userId) async {
    final isar = await DatabaseService.instance;
    
    final user = await isar.users.get(userId);
    if (user != null) {
      user.googleAccountLinked = false;
      user.googleAccountId = null;
      user.updatedAt = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.users.put(user);
      });
    }
  }

  static Future<User?> getCurrentUser() async {
    final isar = await DatabaseService.instance;
    
    // For now, get the first user (in a real app, you'd track the current session)
    return await isar.users.where().findFirst();
  }

  static Future<User?> getUserById(int userId) async {
    final isar = await DatabaseService.instance;
    return await isar.users.get(userId);
  }
}
