import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    if (appProvider.currentRegister != null) {
      if (query.isEmpty) {
        customerProvider.loadCustomers(appProvider.currentRegister!.id, refresh: true);
        setState(() {
          _isSearching = false;
        });
      } else {
        customerProvider.searchCustomers(appProvider.currentRegister!.id, query);
        setState(() {
          _isSearching = true;
        });
      }
    }
  }

  void _showAddCustomerDialog({Customer? customer}) {
    final _nameController = TextEditingController(text: customer?.name ?? '');
    final _emailController = TextEditingController(text: customer?.email ?? '');
    final _phoneController = TextEditingController(text: customer?.phone ?? '');
    final _addressController = TextEditingController(text: customer?.address ?? '');
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'Add Customer' : 'Edit Customer'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final appProvider = Provider.of<AppProvider>(context, listen: false);
                final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
                
                if (appProvider.currentRegister != null) {
                  if (customer == null) {
                    // Add new customer
                    await customerProvider.addCustomer(
                      name: _nameController.text.trim(),
                      registerId: appProvider.currentRegister!.id,
                      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
                    );
                  } else {
                    // Update existing customer
                    customer.name = _nameController.text.trim();
                    customer.email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
                    customer.phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
                    customer.address = _addressController.text.trim().isEmpty ? null : _addressController.text.trim();
                    await customerProvider.updateCustomer(customer);
                  }
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(customer == null ? 'Customer added successfully' : 'Customer updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(customer == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "${customer.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
              await customerProvider.deleteCustomer(customer.id);
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Customer deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          
          // Customer List
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                if (customerProvider.isLoading && customerProvider.customers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (customerProvider.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _isSearching ? 'No customers found' : 'No customers yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!_isSearching)
                          ElevatedButton(
                            onPressed: () => _showAddCustomerDialog(),
                            child: const Text('Add First Customer'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final appProvider = Provider.of<AppProvider>(context, listen: false);
                    if (appProvider.currentRegister != null) {
                      await customerProvider.loadCustomers(
                        appProvider.currentRegister!.id,
                        refresh: true,
                      );
                    }
                  },
                  child: ListView.builder(
                    itemCount: customerProvider.customers.length + (customerProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == customerProvider.customers.length) {
                        // Load more indicator
                        if (!_isSearching) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final appProvider = Provider.of<AppProvider>(context, listen: false);
                            if (appProvider.currentRegister != null) {
                              customerProvider.loadCustomers(appProvider.currentRegister!.id);
                            }
                          });
                        }
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final customer = customerProvider.customers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              customer.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          title: Text(customer.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customer.email != null) Text('Email: ${customer.email}'),
                              if (customer.phone != null) Text('Phone: ${customer.phone}'),
                              if (customer.outstandingBalance > 0)
                                Text(
                                  'Outstanding: ₹${customer.outstandingBalance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showAddCustomerDialog(customer: customer);
                                  break;
                                case 'delete':
                                  _deleteCustomer(customer);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
