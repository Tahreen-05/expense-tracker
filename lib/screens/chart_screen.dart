<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChartScreen extends StatefulWidget {
  final List<Expense> expenses;
  final double totalIncome;

  const ChartScreen({
    super.key,
    required this.expenses,
    required this.totalIncome,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<Expense> weeklyExpenses = [];
  bool isWeeklyLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyExpenses();
  }

  Future<void> _fetchWeeklyExpenses() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final snapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
          .get();

      final expenses = snapshot.docs.map((doc) {
        final data = doc.data();
        final categoryData = Map<String, dynamic>.from(data['category'] ?? {});
        final category = Category.fromEntity(CategoryEntity.fromDocument(categoryData));
        return Expense(
          expenseId: doc.id,
          category: category,
          date: (data['date'] as Timestamp).toDate(),
          amount: data['amount'],
          userId: data['userId'],
        );
      }).toList();

      setState(() {
        weeklyExpenses = expenses;
        isWeeklyLoading = false;
      });
    } catch (e) {
      debugPrint("🔥 Error loading weekly expenses: $e");
      setState(() {
        isWeeklyLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading expenses: $e")),
        );
      }
    }
  }

  int getWeeklyTotal(List<Expense> weeklyExpenses) {
    return weeklyExpenses.fold(0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Category Breakdown'),
              Tab(text: 'Weekly Report'),
              Tab(text: 'Monthly Trends'),
            ],
          ),
        ),
        body: widget.totalIncome <= 0
            ? const Center(
                child: Text(
                  'Please set your monthly income in the profile setup screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : TabBarView(
                children: [
                  _buildPieChart(context),
                  _buildWeeklyReport(),
                  _buildBarChart(),
                ],
              ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final categoryTotals = <String, double>{};
    for (var expense in widget.expenses) {
      categoryTotals[expense.category.name] =
          (categoryTotals[expense.category.name] ?? 0) + expense.amount;
    }

    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No data to show.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: _createPieChartSections(context, categoryTotals),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(categoryTotals),
          const SizedBox(height: 16),
          _buildSummary(context, categoryTotals),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport() {
    final weeklyTotal = getWeeklyTotal(weeklyExpenses);

    return isWeeklyLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Weekly Expense: ₹$weeklyTotal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Expenses this week:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: weeklyExpenses.isEmpty
                      ? const Center(
                          child: Text(
                            "🗓️ No expenses this week.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: weeklyExpenses.length,
                          itemBuilder: (context, index) {
                            final e = weeklyExpenses[index];
                            return Card(
                              child: ListTile(
                                title: Text(e.category.name),
                                subtitle: Text(
                                  '${e.date.toLocal().toString().split(" ")[0]}',
                                ),
                                trailing: Text('₹${e.amount}'),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          );
  }

  Widget _buildBarChart() {
    final monthlyTotals = <String, double>{};
    for (var expense in widget.expenses) {
      final month = DateFormat('yyyy-MM').format(expense.date);
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + expense.amount;
    }

    if (monthlyTotals.isEmpty) {
      return const Center(child: Text('No data to show.'));
    }

    final months = monthlyTotals.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          maxY: widget.totalIncome,
          barGroups: _createBarGroups(monthlyTotals),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Text(months[value.toInt()].substring(5));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, Map<String, double> categoryTotals) {
    final totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final savings = widget.totalIncome - totalExpenses;
    final savingsPercentage = (widget.totalIncome > 0)
        ? (savings / widget.totalIncome * 100).toStringAsFixed(1)
        : '0';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Income: ₹${widget.totalIncome.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Expenses: ₹${totalExpenses.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Savings: ₹${savings.toStringAsFixed(2)} ($savingsPercentage%)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: savings >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
    BuildContext context, Map<String, double> categoryTotals) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
    ];

    return categoryTotals.entries.map((entry) {
      final index = categoryTotals.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${(entry.value / widget.totalIncome * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _createBarGroups(Map<String, double> monthlyTotals) {
    return monthlyTotals.entries.map((entry) {
      final index = monthlyTotals.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> categoryTotals) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: categoryTotals.entries.map((entry) {
        final index = categoryTotals.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              color: colors[index % colors.length],
            ),
            const SizedBox(width: 4),
            Text(entry.key),
          ],
        );
      }).toList(),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:intl/intl.dart';

class ChartScreen extends StatelessWidget {
  final List<Expense> expenses;
  final double totalIncome;

  const ChartScreen({
    super.key,
    required this.expenses,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Category Breakdown'),
              Tab(text: 'Monthly Trends'),
              Tab(text: 'Expense Trend'),
            ],
          ),
        ),
        body: totalIncome <= 0
            ? const Center(
                child: Text(
                  'Please set your monthly income in the profile setup screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : TabBarView(
                children: [
                  _buildPieChart(context),
                  _buildBarChart(),
                  _buildLineChart(context),
                ],
              ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final categoryTotals = <String, double>{};
    for (var expense in expenses) {
      categoryTotals[expense.category.name] =
          (categoryTotals[expense.category.name] ?? 0) + expense.amount;
    }

    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No data to show.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: _createPieChartSections(context, categoryTotals),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(categoryTotals),
          const SizedBox(height: 16),
          _buildSummary(context, categoryTotals),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final monthlyTotals = <String, double>{};
    for (var expense in expenses) {
      final month = DateFormat('yyyy-MM').format(expense.date);
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + expense.amount;
    }

    if (monthlyTotals.isEmpty) {
      return const Center(child: Text('No data to show.'));
    }

    final months = monthlyTotals.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          maxY: totalIncome,
          barGroups: _createBarGroups(monthlyTotals),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Text(months[value.toInt()].substring(5));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final dailyTotals = <String, double>{};
    for (var expense in expenses) {
      final date = DateFormat('yyyy-MM-dd').format(expense.date);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + expense.amount;
    }

    final sortedDates = dailyTotals.keys.toList()..sort();

    if (sortedDates.isEmpty) {
      return const Center(child: Text('No data to show.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < sortedDates.length) {
                    return Text(
                      DateFormat('dd')
                          .format(DateTime.parse(sortedDates[value.toInt()])),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              spots: sortedDates.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), dailyTotals[entry.value]!);
              }).toList(),
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
      BuildContext context, Map<String, double> categoryTotals) {
    final totalExpenses =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final savings = totalIncome - totalExpenses;
    final savingsPercentage = (totalIncome > 0)
        ? (savings / totalIncome * 100).toStringAsFixed(1)
        : '0';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Income: \$${totalIncome.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Savings: \$${savings.toStringAsFixed(2)} ($savingsPercentage%)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: savings >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
      BuildContext context, Map<String, double> categoryTotals) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
    ];

    return categoryTotals.entries.map((entry) {
      final index = categoryTotals.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${(entry.value / totalIncome * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<BarChartGroupData> _createBarGroups(Map<String, double> monthlyTotals) {
    return monthlyTotals.entries.map((entry) {
      final index = monthlyTotals.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> categoryTotals) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: categoryTotals.entries.map((entry) {
        final index = categoryTotals.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              color: colors[index % colors.length],
            ),
            const SizedBox(width: 4),
            Text(entry.key),
          ],
        );
      }).toList(),
    );
  }
}
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
