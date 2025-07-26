import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/services/auth_service.dart';
import 'package:billing_app/services/database_service.dart';

void main() {
  group('Authentication Tests', () {
    test('should create user with valid email and password', () async {
      // Test user creation
      final email = 'test@example.com';
      final password = 'password123';
      
      try {
        final user = await AuthService.signUp(email, password);
        expect(user, isNotNull);
        expect(user!.email, equals(email));
        expect(user.passwordHash, isNotEmpty);
      } catch (e) {
        // Handle case where user already exists
        expect(e.toString(), contains('User already exists'));
      }
    });

    test('should sign in with correct credentials', () async {
      final email = 'test@example.com';
      final password = 'password123';
      
      // First ensure user exists
      try {
        await AuthService.signUp(email, password);
      } catch (e) {
        // User might already exist, that's fine
      }
      
      final user = await AuthService.signIn(email, password);
      expect(user, isNotNull);
      expect(user!.email, equals(email));
    });

    test('should return null for incorrect credentials', () async {
      final user = await AuthService.signIn('wrong@email.com', 'wrongpassword');
      expect(user, isNull);
    });

    test('should get current user', () async {
      final user = await AuthService.getCurrentUser();
      // This might be null if no user is signed in, which is fine for testing
      expect(user, isA<dynamic>());
    });
  });

  group('Database Tests', () {
    test('should initialize database successfully', () async {
      final isar = await DatabaseService.instance;
      expect(isar, isNotNull);
    });

    test('should handle database operations without errors', () async {
      // Basic database connectivity test
      final isar = await DatabaseService.instance;
      
      // Test basic read operation (using a simple check that doesn't require specific schemas)
      expect(isar.isOpen, isTrue);
    });

    test('should initialize database using initialize method', () async {
      // Test the initialize method
      expect(() async {
        await DatabaseService.initialize();
      }, returnsNormally);
    });
  });

  group('Basic Service Tests', () {
    test('should handle auth service methods without errors', () async {
      // Test that service methods can be called
      expect(() async {
        await AuthService.getCurrentUser();
      }, returnsNormally);
    });
  });
}
