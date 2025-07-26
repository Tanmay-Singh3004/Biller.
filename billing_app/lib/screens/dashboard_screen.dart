import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/item_provider.dart';
import '../providers/transaction_provider.dart';
import 'customers_screen.dart';
import 'items_screen.dart';
import 'transactions_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadData() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.currentRegister != null) {
      final registerId = appProvider.currentRegister!.id;
      
      Provider.of<CustomerProvider>(context, listen: false)
          .loadCustomers(registerId, refresh: true);
      Provider.of<ItemProvider>(context, listen: false)
          .loadItems(registerId, refresh: true);
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions(registerId, refresh: true);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.currentRegister == null) {
          return const Scaffold(
            body: Center(child: Text('No register selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(appProvider.currentRegister!.name),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              _buildDashboardHome(),
              const TransactionsScreen(),
              const CustomersScreen(),
              const ItemsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Customers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory),
                label: 'Stock',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardHome() {
    return Consumer3<TransactionProvider, CustomerProvider, ItemProvider>(
      builder: (context, transactionProvider, customerProvider, itemProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Transactions',
                      '${transactionProvider.transactions.length}',
                      Icons.receipt,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Customers',
                      '${customerProvider.customers.length}',
                      Icons.people,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Stock Items',
                      '${itemProvider.items.length}',
                      Icons.inventory,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Sales',
                      _calculateTotalSales(transactionProvider.transactions),
                      Icons.attach_money,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Transactions
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              if (transactionProvider.transactions.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _onItemTapped(1),
                          child: const Text('Create First Transaction'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactionProvider.transactions.take(5).length,
                  itemBuilder: (context, index) {
                    final transaction = transactionProvider.transactions[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: const Icon(Icons.receipt, color: Colors.blue),
                        ),
                        title: Text('Transaction #${transaction.id}'),
                        subtitle: Text(
                          '${transaction.transactionDate.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${transaction.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (transaction.outstandingAmount > 0)
                              Text(
                                'Outstanding: ₹${transaction.outstandingAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _onItemTapped(1),
                      ),
                    );
                  },
                ),
              
              if (transactionProvider.transactions.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: TextButton(
                      onPressed: () => _onItemTapped(1),
                      child: const Text('View All Transactions'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalSales(List transactions) {
    double total = 0;
    for (var transaction in transactions) {
      total += transaction.totalAmount;
    }
    return '₹${total.toStringAsFixed(2)}';
  }
}
