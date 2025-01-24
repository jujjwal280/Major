import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:start1/screens/dashboard_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  double? _amount;
  String? _description;
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Groceries',
    'Transportation',
    'Entertainment',
    'Rent',
    'Dining Out',
  ];

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          DateTime date = _selectedDate ?? DateTime.now();

          String month = DateFormat('MMMM').format(date);
          int weekOfMonth = ((date.day - 1) ~/ 7) + 1;
          String day = DateFormat('yyyy-MM-dd').format(date);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .add({
            'amount': _amount,
            'category': _selectedCategory,
            'description': _description ?? '',
            'date': Timestamp.fromDate(date),
            'month': month,
            'week': 'Week $weekOfMonth',
            'day': day,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction added successfully!')),
          );

          _formKey.currentState!.reset();
          Navigator.pop(context);
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add transaction: $error')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    final CollectionReference transactions = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('transactions');

    return Scaffold(
      backgroundColor: const Color(0xFF9FE7F5),
      appBar: AppBar(
        title: const Text("Transactions",
        style: TextStyle(color: Colors.white)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()),);
          },
        ),
        backgroundColor: const Color(0xFF053F5C),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactions.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load transactions. Please try again.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'No transactions found. Add your first transaction!',
                  style: TextStyle(
                      fontSize: 22, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          final dataDocs = snapshot.data!.docs;

          double totalExpenditure = 0.0;
          for (var doc in dataDocs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['amount'] != null) {
              totalExpenditure += (data['amount'] as num).toDouble();
            }
          }

          Map<String, Map<int, Map<String, List<Widget>>>> groupedTransactions = {};
          Map<String, Map<int, double>> monthlyExpenditure = {};

          for (var doc in dataDocs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['amount'] == null || data['date'] == null || data['category'] == null) {
              continue;
            }

            DateTime date = (data['date'] as Timestamp).toDate();
            String monthKey = "${date.year}-${date.month}";

            String monthName = DateFormat('MMMM').format(date);
            int weekOfMonth = ((date.day - 1) ~/ 7) + 1;
            String fullDateKey = "${date.year}-${date.month}-${date.day}";
            String dayKey = DateFormat('yyyy-MM-dd').format(date);

            Color categoryColor = categoryColors[data['category']] ?? Colors.grey;

            if (!groupedTransactions.containsKey(monthName)) {
              groupedTransactions[monthName] = {};
              monthlyExpenditure[monthName] = {};
            }

            if (!groupedTransactions[monthName]!.containsKey(weekOfMonth)) {
              groupedTransactions[monthName]![weekOfMonth] = {};
            }

            if (!groupedTransactions[monthName]![weekOfMonth]!.containsKey(dayKey)) {
              groupedTransactions[monthName]![weekOfMonth]![dayKey] = [];
            }

            groupedTransactions[monthName]![weekOfMonth]![dayKey]!.add(
              Card(
                color: categoryColor,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Color(0xFF053F5C)),
                  title: Text(data['category'] ?? 'Unknown'),
                  subtitle: Text(data['description'] ?? 'No description'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "₹${(data['amount'] ?? 0.0).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () async {
                          await transactions.doc(doc.id).delete();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );

            // Ensure monthlyExpenditure and weekly breakdown are properly initialized and updated
            monthlyExpenditure.putIfAbsent(monthName, () => {});
            monthlyExpenditure[monthName]!.putIfAbsent(weekOfMonth, () => 0.0);

            // Add the expenditure for the month and week
            monthlyExpenditure[monthName]![weekOfMonth] = (monthlyExpenditure[monthName]![weekOfMonth] ?? 0) + (data['amount'] as num).toDouble();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  elevation: 4,
                  color: Colors.white.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Overall Expenditure",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF053F5C),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "₹${totalExpenditure.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                for (var month in groupedTransactions.keys)
                  ExpansionTile(
                    title: Text(
                      '$month (₹${monthlyExpenditure[month]?.values.fold(0.0, (previousValue, element) => previousValue + element).toStringAsFixed(2) ?? '0.00'})',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      for (var week in groupedTransactions[month]!.keys.toList()..sort())
                        ExpansionTile(
                          title: Text(
                            'Week $week (₹${monthlyExpenditure[month]?[week]?.toStringAsFixed(2) ?? '0.00'})',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          children: [
                            for (var day in groupedTransactions[month]![week]!.keys.toList()..sort())
                              ExpansionTile(
                                title: Text(
                                  day,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                children: groupedTransactions[month]![week]![day]!,
                              ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFF9FE7F5),
            builder: (ctx) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (value) => setState(() {
                            _selectedCategory = value;
                          }),
                          decoration: InputDecoration(
                            labelText: 'Category', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.6),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                            ),
                          ),
                          validator: (value) =>
                          value == null ? 'Please select a category' : null,
                        ),
                        const SizedBox(height: 10),
                        // Amount Input
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.6),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            final parsed = double.tryParse(value);
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid positive number';
                            }
                            return null;
                          },
                          onSaved: (value) => _amount = double.parse(value!),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        // Description Input
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Description', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.6),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                            ),
                          ),
                          onSaved: (value) => _description = value,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : '${_selectedDate!.toLocal()}'.split(' ')[0],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today, color: Color(0xFF1E5C78)
                              ),
                              onPressed: () => _selectDate(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Add Transaction Button
                        ElevatedButton(
                          onPressed: _addTransaction,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: const Color(0xFF053F5C),
                          ),
                          child: const Text(
                            'Add Transaction',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF053F5C),
        child: const Icon(Icons.add,color: Colors.white),
      ),
    );
  }
}

extension on Map<int, double>? {
  toStringAsFixed(int i) {}
}

final Map<String, Color> categoryColors = {
  'Groceries': const Color(0xFFECB762),
  'Transportation': const Color(0xFFFFE6AE),
  'Entertainment': const Color(0xFFF4BAB0),
  'Rent': const Color(0xFF7EA59B),
  'Dining Out': const Color(0xFFF47F7D),
};