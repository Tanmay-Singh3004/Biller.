import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/register.dart';
import 'dashboard_screen.dart';

class RegisterSelectionScreen extends StatefulWidget {
  const RegisterSelectionScreen({super.key});

  @override
  State<RegisterSelectionScreen> createState() => _RegisterSelectionScreenState();
}

class _RegisterSelectionScreenState extends State<RegisterSelectionScreen> {
  final _registerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadUserRegisters();
    });
  }

  @override
  void dispose() {
    _registerNameController.dispose();
    super.dispose();
  }

  Future<void> _createRegister() async {
    if (_registerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a register name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.createRegister(_registerNameController.text.trim());
    _registerNameController.clear();
  }

  void _selectRegister(Register register) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setCurrentRegister(register);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Register'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false).signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appProvider.userRegisters.isEmpty) {
            return _buildCreateRegisterView();
          }

          return _buildRegisterListView(appProvider.userRegisters);
        },
      ),
    );
  }

  Widget _buildCreateRegisterView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.store,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'Create Your First Register',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'A register helps you organize your business transactions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          TextField(
            controller: _registerNameController,
            decoration: const InputDecoration(
              labelText: 'Register Name',
              hintText: 'e.g., Main Store, Online Sales',
              prefixIcon: Icon(Icons.store),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return ElevatedButton(
                onPressed: appProvider.isLoading ? null : _createRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: appProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Register', style: TextStyle(fontSize: 16)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterListView(List<Register> registers) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: registers.length,
            itemBuilder: (context, index) {
              final register = registers[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.store, color: Colors.blue),
                  title: Text(register.name),
                  subtitle: Text('Created: ${register.createdAt.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectRegister(register),
                ),
              );
            },
          ),
        ),
        
        // Add New Register Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Register',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _registerNameController,
                decoration: const InputDecoration(
                  labelText: 'Register Name',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return ElevatedButton(
                    onPressed: appProvider.isLoading ? null : _createRegister,
                    child: appProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Register'),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
