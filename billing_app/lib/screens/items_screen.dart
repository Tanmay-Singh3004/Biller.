import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/item_provider.dart';
import '../models/item.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    
    if (appProvider.currentRegister != null) {
      if (query.isEmpty) {
        itemProvider.loadItems(appProvider.currentRegister!.id, refresh: true);
        setState(() {
          _isSearching = false;
        });
      } else {
        itemProvider.searchItems(appProvider.currentRegister!.id, query);
        setState(() {
          _isSearching = true;
        });
      }
    }
  }

  void _showAddItemDialog({Item? item}) {
    final _nameController = TextEditingController(text: item?.name ?? '');
    final _descriptionController = TextEditingController(text: item?.description ?? '');
    final _stockController = TextEditingController(text: item?.stockQuantity.toString() ?? '0');
    final _priceController = TextEditingController(text: item?.unitPrice.toString() ?? '0.0');
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Edit Item'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter stock quantity';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Unit Price *',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter unit price';
                    }
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
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
                final itemProvider = Provider.of<ItemProvider>(context, listen: false);
                
                if (appProvider.currentRegister != null) {
                  if (item == null) {
                    // Add new item
                    await itemProvider.addItem(
                      name: _nameController.text.trim(),
                      registerId: appProvider.currentRegister!.id,
                      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                      stockQuantity: int.parse(_stockController.text),
                      unitPrice: double.parse(_priceController.text),
                    );
                  } else {
                    // Update existing item
                    item.name = _nameController.text.trim();
                    item.description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
                    item.stockQuantity = int.parse(_stockController.text);
                    item.unitPrice = double.parse(_priceController.text);
                    await itemProvider.updateItem(item);
                  }
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(item == null ? 'Item added successfully' : 'Item updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(item == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final itemProvider = Provider.of<ItemProvider>(context, listen: false);
              await itemProvider.deleteItem(item.id);
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted successfully'),
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
        title: const Text('Stock Items'),
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
                hintText: 'Search items...',
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
          
          // Items List
          Expanded(
            child: Consumer<ItemProvider>(
              builder: (context, itemProvider, child) {
                if (itemProvider.isLoading && itemProvider.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (itemProvider.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _isSearching ? 'No items found' : 'No items yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!_isSearching)
                          ElevatedButton(
                            onPressed: () => _showAddItemDialog(),
                            child: const Text('Add First Item'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final appProvider = Provider.of<AppProvider>(context, listen: false);
                    if (appProvider.currentRegister != null) {
                      await itemProvider.loadItems(
                        appProvider.currentRegister!.id,
                        refresh: true,
                      );
                    }
                  },
                  child: ListView.builder(
                    itemCount: itemProvider.items.length + (itemProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == itemProvider.items.length) {
                        // Load more indicator
                        if (!_isSearching) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final appProvider = Provider.of<AppProvider>(context, listen: false);
                            if (appProvider.currentRegister != null) {
                              itemProvider.loadItems(appProvider.currentRegister!.id);
                            }
                          });
                        }
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = itemProvider.items[index];
                      final isLowStock = item.stockQuantity <= 5;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isLowStock ? Colors.red[100] : Colors.blue[100],
                            child: Icon(
                              Icons.inventory_2,
                              color: isLowStock ? Colors.red : Colors.blue,
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.description != null) 
                                Text(item.description!, maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('Price: ₹${item.unitPrice.toStringAsFixed(2)}'),
                              Row(
                                children: [
                                  Text(
                                    'Stock: ${item.stockQuantity}',
                                    style: TextStyle(
                                      color: isLowStock ? Colors.red[600] : null,
                                      fontWeight: isLowStock ? FontWeight.bold : null,
                                    ),
                                  ),
                                  if (isLowStock) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'LOW STOCK',
                                        style: TextStyle(
                                          color: Colors.red[800],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showAddItemDialog(item: item);
                                  break;
                                case 'delete':
                                  _deleteItem(item);
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
        onPressed: () => _showAddItemDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
