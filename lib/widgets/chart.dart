import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class ChartWidget extends StatelessWidget {
  final List<Transaction> transactions;

  const ChartWidget({super.key, required this.transactions});

  Map<String, double> get _categoryData {
    final Map<String, double> data = {};
    for (var t in transactions.where((t) => t.isExpense)) {
      data[t.category] = (data[t.category] ?? 0) + t.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final data = _categoryData;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No expense data yet!',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    final colors = [
      Colors.orange, Colors.blue, Colors.pink,
      Colors.purple, Colors.red, Colors.teal, Colors.grey,
    ];

    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Expense by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: List.generate(entries.length, (i) {
                  final percentage = (entries[i].value / total) * 100;
                  return PieChartSectionData(
                    value: entries[i].value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    color: colors[i % colors.length],
                    radius: 80,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  );
                }),
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(entries.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(entries[i].key,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(
                    '₹${entries[i].value.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}