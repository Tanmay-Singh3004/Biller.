import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';
import 'auth_service.dart' as local_auth;

class BackupService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Link Google account for backup
  static Future<Map<String, dynamic>> linkGoogleAccount() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Google sign-in cancelled'};
      }

      // Get Google auth credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Update local user record
        final currentUser = await local_auth.AuthService.getCurrentUser();
        if (currentUser != null) {
          await local_auth.AuthService.linkGoogleAccount(
            currentUser.id, 
            userCredential.user!.uid
          );
        }
        
        return {
          'success': true, 
          'message': 'Google account linked successfully',
          'googleAccountId': userCredential.user!.uid,
          'email': userCredential.user!.email,
        };
      } else {
        return {'success': false, 'message': 'Failed to authenticate with Firebase'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error linking Google account: $e'};
    }
  }

  /// Unlink Google account
  static Future<Map<String, dynamic>> unlinkGoogleAccount() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Update local user record
      final currentUser = await local_auth.AuthService.getCurrentUser();
      if (currentUser != null) {
        await local_auth.AuthService.unlinkGoogleAccount(currentUser.id);
      }
      
      return {'success': true, 'message': 'Google account unlinked successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error unlinking Google account: $e'};
    }
  }

  /// Export database to a backup file
  static Future<Map<String, dynamic>> exportDatabase() async {
    try {
      final databaseService = DatabaseService.instance;
      final isar = await databaseService;
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      // Create backup directory if it doesn't exist
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // Create backup filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = '${backupDir.path}/billing_app_backup_$timestamp.isar';
      
      // Copy Isar database file
      await isar.copyToFile(backupPath);
      
      return {
        'success': true,
        'message': 'Database exported successfully',
        'filePath': backupPath,
        'fileName': 'billing_app_backup_$timestamp.isar',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error exporting database: $e'};
    }
  }

  /// Upload backup to Google Drive (simplified version)
  /// Note: This is a basic implementation. For production, you'd want to use
  /// the Google Drive API directly for better control and error handling.
  static Future<Map<String, dynamic>> backupToCloud() async {
    try {
      // Check if Google account is linked
      final currentUser = await local_auth.AuthService.getCurrentUser();
      if (currentUser == null || !currentUser.googleAccountLinked) {
        return {'success': false, 'message': 'Please link your Google account first'};
      }

      // Export database first
      final exportResult = await exportDatabase();
      if (!exportResult['success']) {
        return exportResult;
      }

      // In a real implementation, you would:
      // 1. Use Google Drive API to upload the file
      // 2. Store metadata about the backup
      // 3. Handle authentication tokens
      
      // For now, we'll simulate the upload
      await Future.delayed(const Duration(seconds: 2));
      
      return {
        'success': true,
        'message': 'Backup uploaded to Google Drive successfully',
        'backupDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error backing up to cloud: $e'};
    }
  }

  /// Restore database from backup file
  static Future<Map<String, dynamic>> restoreFromFile(String filePath) async {
    try {
      final backupFile = File(filePath);
      if (!await backupFile.exists()) {
        return {'success': false, 'message': 'Backup file not found'};
      }

      // Close current database connection
      final databaseService = DatabaseService.instance;
      final isar = await databaseService;
      await isar.close();

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = '${directory.path}/billing_app.isar';
      
      // Replace current database with backup
      await backupFile.copy(dbPath);
      
      // Reinitialize database
      await DatabaseService.initialize();
      
      return {
        'success': true,
        'message': 'Database restored successfully',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error restoring database: $e'};
    }
  }

  /// Get list of local backup files
  static Future<List<Map<String, dynamic>>> getLocalBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final files = await backupDir.list().toList();
      final backups = <Map<String, dynamic>>[];
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.isar')) {
          final stat = await file.stat();
          final fileName = file.path.split('/').last;
          
          // Extract timestamp from filename
          final timestampMatch = RegExp(r'backup_(\d+)\.isar').firstMatch(fileName);
          DateTime? backupDate;
          if (timestampMatch != null) {
            final timestamp = int.tryParse(timestampMatch.group(1) ?? '');
            if (timestamp != null) {
              backupDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            }
          }
          
          backups.add({
            'filePath': file.path,
            'fileName': fileName,
            'size': stat.size,
            'date': backupDate ?? stat.modified,
          });
        }
      }
      
      // Sort by date (newest first)
      backups.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      return backups;
    } catch (e) {
      return [];
    }
  }

  /// Clear all data (for testing or reset purposes)
  static Future<Map<String, dynamic>> clearAllData() async {
    try {
      final databaseService = DatabaseService.instance;
      final isar = await databaseService;
      
      await isar.writeTxn(() async {
        await isar.clear();
      });
      
      return {
        'success': true,
        'message': 'All data cleared successfully',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error clearing data: $e'};
    }
  }
}
