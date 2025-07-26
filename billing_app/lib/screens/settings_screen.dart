import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/backup_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final user = appProvider.currentUser;
          final register = appProvider.currentRegister;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Profile Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user != null) ...[
                        ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(user.email),
                          subtitle: Text('User ID: ${user.id}'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              user.googleAccountLinked ? Icons.check_circle : Icons.cancel,
                              color: user.googleAccountLinked ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.googleAccountLinked 
                                  ? 'Google Account Linked' 
                                  : 'Google Account Not Linked',
                              style: TextStyle(
                                color: user.googleAccountLinked ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Current Register Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Register',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (register != null) ...[
                        ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.store),
                          ),
                          title: Text(register.name),
                          subtitle: Text('Created: ${register.createdAt.toLocal().toString().split(' ')[0]}'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Google Account Management Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Account',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.cloud_sync, color: Colors.blue),
                        title: const Text('Link Google Account'),
                        subtitle: const Text('Enable backup and sync across devices'),
                        trailing: Switch(
                          value: user?.googleAccountLinked ?? false,
                          onChanged: (value) async {
                            if (value) {
                              await _linkGoogleAccount(context);
                            } else {
                              await _unlinkGoogleAccount(context);
                            }
                          },
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (user?.googleAccountLinked ?? false) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.backup, color: Colors.green),
                          title: const Text('Backup Data'),
                          subtitle: const Text('Upload your data to Google Drive'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            _backupData(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.restore, color: Colors.orange),
                          title: const Text('Restore Data'),
                          subtitle: const Text('Download your data from Google Drive'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            _restoreData(context);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // App Information Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.info, color: Colors.blue),
                        title: const Text('Version'),
                        subtitle: const Text('1.0.0'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.help, color: Colors.green),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          _showHelpDialog(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip, color: Colors.orange),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          _showPrivacyPolicy(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Danger Zone Section
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red[700]),
                        title: Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        subtitle: const Text('Sign out from your account'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          _showSignOutDialog(context, appProvider);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_forever, color: Colors.red[700]),
                        title: Text(
                          'Clear All Data',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        subtitle: const Text('Delete all local data permanently'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          _showClearDataDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Billing App Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Manage customers and their contact information'),
              Text('• Track inventory with stock quantities and pricing'),
              Text('• Create transactions and generate invoices'),
              Text('• Record payments and track outstanding balances'),
              Text('• Generate PDF invoices for transactions'),
              Text('• Multiple register support for different business units'),
              SizedBox(height: 16),
              Text(
                'Need Help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('For support, please contact: support@billingapp.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data Collection:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• We store your business data locally on your device'),
              Text('• No personal data is shared with third parties'),
              Text('• Google account linking is optional for backup purposes'),
              SizedBox(height: 16),
              Text(
                'Data Security:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• All data is encrypted and stored securely'),
              Text('• You have full control over your data'),
              Text('• You can delete all data at any time'),
              SizedBox(height: 16),
              Text(
                'Contact:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('For privacy concerns: privacy@billingapp.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? You will need to log in again to access your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              appProvider.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your data including customers, items, transactions, and settings. This action cannot be undone.\n\nAre you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  // Google Account Management Methods
  Future<void> _linkGoogleAccount(BuildContext context) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Linking Google Account...'),
          ],
        ),
      ),
    );

    try {
      final result = await BackupService.linkGoogleAccount();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (result['success']) {
          // Refresh the current user data
          await appProvider.refreshCurrentUser();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error linking Google account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unlinkGoogleAccount(BuildContext context) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Google Account'),
        content: const Text('Are you sure you want to unlink your Google account? This will disable backup functionality.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await BackupService.unlinkGoogleAccount();
      
      if (context.mounted) {
        // Refresh the current user data
        await appProvider.refreshCurrentUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error unlinking Google account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _backupData(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Backing up data...'),
          ],
        ),
      ),
    );

    try {
      final result = await BackupService.backupToCloud();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error backing up data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      final backups = await BackupService.getLocalBackups();
      
      if (context.mounted) {
        if (backups.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No local backups found'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Show backup selection dialog
        final selectedBackup = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Backup to Restore'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: backups.length,
                itemBuilder: (context, index) {
                  final backup = backups[index];
                  final date = backup['date'] as DateTime;
                  
                  return ListTile(
                    title: Text(backup['fileName']),
                    subtitle: Text('${date.toLocal().toString().split('.')[0]}'),
                    trailing: Text('${(backup['size'] / 1024).toStringAsFixed(1)} KB'),
                    onTap: () => Navigator.of(context).pop(backup),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );

        if (selectedBackup != null) {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Restore'),
              content: const Text('This will replace all current data with the backup. This action cannot be undone. Are you sure?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Restore'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Restoring data...'),
                  ],
                ),
              ),
            );

            try {
              final result = await BackupService.restoreFromFile(selectedBackup['filePath']);
              
              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );

                if (result['success']) {
                  // Restart the app or refresh all data
                  final appProvider = Provider.of<AppProvider>(context, listen: false);
                  await appProvider.refreshCurrentUser();
                }
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error restoring data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing backups: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Clearing all data...'),
          ],
        ),
      ),
    );

    try {
      final result = await BackupService.clearAllData();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          // Sign out and redirect to login
          final appProvider = Provider.of<AppProvider>(context, listen: false);
          appProvider.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
