import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final Transaction transaction;
  final Function(String) onDelete;

  const TransactionList({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.fastfood;
      case 'Travel': return Icons.flight;
      case 'Shopping': return Icons.shopping_bag;
      case 'Bills': return Icons.receipt;
      case 'Health': return Icons.medical_services;
      case 'Entertainment': return Icons.movie;
      case 'Salary': return Icons.work;
      case 'Freelance': return Icons.computer;
      case 'Business': return Icons.business;
      case 'Gift': return Icons.card_giftcard;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Travel': return Colors.blue;
      case 'Shopping': return Colors.pink;
      case 'Bills': return Colors.purple;
      case 'Health': return Colors.red;
      case 'Entertainment': return Colors.teal;
      case 'Salary': return Colors.green;
      case 'Freelance': return Colors.indigo;
      case 'Business': return Colors.brown;
      case 'Gift': return Colors.amber;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(transaction.category);
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(transaction.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getCategoryIcon(transaction.category), color: color),
          ),
          title: Text(transaction.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            '${transaction.category} • ${DateFormat('dd MMM yyyy').format(transaction.date)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          trailing: Text(
            '${transaction.isExpense ? '-' : '+'}₹${NumberFormat('#,##,###').format(transaction.amount)}',
            style: TextStyle(
              color: transaction.isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}