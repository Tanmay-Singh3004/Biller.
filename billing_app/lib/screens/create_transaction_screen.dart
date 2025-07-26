import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/item_provider.dart';
import '../models/customer.dart';
import '../models/item.dart';
import '../services/transaction_service.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  Customer? _selectedCustomer;
  final List<TransactionItemData> _selectedItems = [];
  final _paymentController = TextEditingController(text: '0.0');
  final _customerSearchController = TextEditingController();
  final _itemSearchController = TextEditingController();
  bool _isCreatingTransaction = false;

  double get _totalAmount {
    return _selectedItems.fold(0.0, (sum, item) => sum + (item.quantity * item.pricePerUnit));
  }

  double get _outstandingAmount {
    final payment = double.tryParse(_paymentController.text) ?? 0.0;
    return _totalAmount - payment;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _paymentController.dispose();
    _customerSearchController.dispose();
    _itemSearchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.currentRegister != null) {
      final registerId = appProvider.currentRegister!.id;
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers(registerId, refresh: true);
      Provider.of<ItemProvider>(context, listen: false).loadItems(registerId, refresh: true);
    }
  }

  void _showCustomerSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Customer'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: _customerSearchController,
                  decoration: const InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) {
                    final appProvider = Provider.of<AppProvider>(context, listen: false);
                    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
                    if (appProvider.currentRegister != null) {
                      if (query.isEmpty) {
                        customerProvider.loadCustomers(appProvider.currentRegister!.id, refresh: true);
                      } else {
                        customerProvider.searchCustomers(appProvider.currentRegister!.id, query);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<CustomerProvider>(
                    builder: (context, customerProvider, child) {
                      if (customerProvider.customers.isEmpty) {
                        return const Center(child: Text('No customers found'));
                      }
                      return ListView.builder(
                        itemCount: customerProvider.customers.length,
                        itemBuilder: (context, index) {
                          final customer = customerProvider.customers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(customer.name.substring(0, 1).toUpperCase()),
                            ),
                            title: Text(customer.name),
                            subtitle: customer.phone != null ? Text(customer.phone!) : null,
                            onTap: () {
                              setState(() {
                                _selectedCustomer = customer;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _showAddCustomerDialog(),
              child: const Text('Add New Customer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog() {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _addressController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    Navigator.of(context).pop(); // Close customer selection dialog

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
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
                  await customerProvider.addCustomer(
                    name: _nameController.text.trim(),
                    registerId: appProvider.currentRegister!.id,
                    email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                    phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                    address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
                  );
                  
                  // Set the newly created customer as selected
                  if (customerProvider.customers.isNotEmpty) {
                    setState(() {
                      _selectedCustomer = customerProvider.customers.first;
                    });
                  }
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer added and selected'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }

  void _showItemSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Items'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: _itemSearchController,
                  decoration: const InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) {
                    final appProvider = Provider.of<AppProvider>(context, listen: false);
                    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
                    if (appProvider.currentRegister != null) {
                      if (query.isEmpty) {
                        itemProvider.loadItems(appProvider.currentRegister!.id, refresh: true);
                      } else {
                        itemProvider.searchItems(appProvider.currentRegister!.id, query);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<ItemProvider>(
                    builder: (context, itemProvider, child) {
                      if (itemProvider.items.isEmpty) {
                        return const Center(child: Text('No items found'));
                      }
                      return ListView.builder(
                        itemCount: itemProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = itemProvider.items[index];
                          final isSelected = _selectedItems.any((selectedItem) => selectedItem.itemId == item.id);
                          final isOutOfStock = item.stockQuantity <= 0;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isOutOfStock ? Colors.red[100] : Colors.blue[100],
                              child: Icon(
                                Icons.inventory_2,
                                color: isOutOfStock ? Colors.red : Colors.blue,
                              ),
                            ),
                            title: Text(item.name),
                            subtitle: Text('Stock: ${item.stockQuantity} • ₹${item.unitPrice.toStringAsFixed(2)}'),
                            trailing: isSelected 
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : isOutOfStock 
                                    ? const Text('Out of Stock', style: TextStyle(color: Colors.red))
                                    : null,
                            enabled: !isOutOfStock,
                            onTap: isOutOfStock ? null : () {
                              if (!isSelected) {
                                _addItemToTransaction(item);
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _addItemToTransaction(Item item) {
    final _quantityController = TextEditingController(text: '1');
    final _priceController = TextEditingController(text: item.unitPrice.toString());
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${item.name}'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available Stock: ${item.stockQuantity}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  if (quantity > item.stockQuantity) {
                    return 'Quantity cannot exceed available stock';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Unit',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final quantity = int.parse(_quantityController.text);
                final price = double.parse(_priceController.text);
                
                setState(() {
                  _selectedItems.add(TransactionItemData(
                    itemId: item.id,
                    quantity: quantity,
                    pricePerUnit: price,
                  ));
                });
                
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _createTransaction() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final payment = double.tryParse(_paymentController.text) ?? 0.0;
    if (payment < 0 || payment > _totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid payment amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingTransaction = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

      if (appProvider.currentRegister != null) {
        await transactionProvider.createTransaction(
          customerId: _selectedCustomer!.id,
          registerId: appProvider.currentRegister!.id,
          items: _selectedItems,
          paymentReceived: payment,
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingTransaction = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Transaction'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customer Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedCustomer == null)
                      ElevatedButton.icon(
                        onPressed: _showCustomerSelectionDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Select Customer'),
                      )
                    else
                      ListTile(
                        leading: CircleAvatar(
                          child: Text(_selectedCustomer!.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text(_selectedCustomer!.name),
                        subtitle: _selectedCustomer!.phone != null ? Text(_selectedCustomer!.phone!) : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.change_circle),
                          onPressed: _showCustomerSelectionDialog,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Items Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showItemSelectionDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedItems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No items added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = _selectedItems[index];
                          final total = item.quantity * item.pricePerUnit;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text((index + 1).toString()),
                            ),
                            title: Consumer<ItemProvider>(
                              builder: (context, itemProvider, child) {
                                final itemDetails = itemProvider.items
                                    .where((i) => i.id == item.itemId)
                                    .firstOrNull;
                                return Text(itemDetails?.name ?? 'Item #${item.itemId}');
                              },
                            ),
                            subtitle: Text(
                              'Qty: ${item.quantity} × ₹${item.pricePerUnit.toStringAsFixed(2)} = ₹${total.toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:'),
                        Text(
                          '₹${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _paymentController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Received',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Outstanding:'),
                        Text(
                          '₹${_outstandingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _outstandingAmount > 0 ? Colors.red[600] : Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Create Transaction Button
            ElevatedButton(
              onPressed: _isCreatingTransaction ? null : _createTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isCreatingTransaction
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Create Transaction',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
