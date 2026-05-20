import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../widgets/transaction_list.dart';
import '../widgets/chart.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> _transactions = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data);
      setState(() {
        _transactions = jsonList
            .map((e) => Transaction.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      });
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
    json.encode(_transactions.map((e) => e.toMap()).toList());
    await prefs.setString('transactions', data);
  }

  void _addTransaction(Transaction t) {
    setState(() {
      _transactions.insert(0, t);
    });
    _saveTransactions();
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
    _saveTransactions();
  }

  double get _totalIncome => _transactions
      .where((t) => !t.isExpense)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  void _openAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
    if (result != null) {
      _addTransaction(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _selectedIndex == 0 ? _buildHome() : _buildChart(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Charts',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTransaction,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF6C63FF),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 80, left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##,###.##').format(_balance)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Income',
                            _totalIncome,
                            Icons.arrow_downward,
                            Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryCard(
                            'Expense',
                            _totalExpense,
                            Icons.arrow_upward,
                            Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          title: const Text('Expense Tracker',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
        ),
        _transactions.isEmpty
            ? SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.receipt_long,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No transactions yet!',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            ),
          ),
        )
            : SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) => TransactionList(
              transaction: _transactions[index],
              onDelete: _deleteTransaction,
            ),
            childCount: _transactions.length,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Column(
      children: [
        AppBar(
          title: const Text('Spending Chart'),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        Expanded(
          child: ChartWidget(transactions: _transactions),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                '₹${NumberFormat('#,##,###').format(amount)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}