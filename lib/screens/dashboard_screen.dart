import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart for pie chart

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalExpenses = 0;
  Map<String, double> categoryExpenses = {};
  String? _username;
  String? _account_number;
  String? _bank_name;
  bool isProfile = false;
  bool isTransaction = false;
  bool isLogout = false;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc['username'] ?? 'User Name';
            _account_number = userDoc['account_number'] ?? 'Account Number';
            _bank_name = userDoc['bank_name'] ?? 'Bank Name';

          });
        }
      } catch (e) {
        print("Error fetching user details: $e");
      }
    }
  }

  void _fetchExpenses() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final CollectionReference transactions = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions');

      try {
        final QuerySnapshot snapshot = await transactions.get();
        final dataDocs = snapshot.docs;

        Map<String, double> tempCategoryExpenses = {};
        double total = 0;

        for (var doc in dataDocs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['amount'] != null && data['category'] != null) {
            final category = data['category'];
            final amount = data['amount'].toDouble();

            // Add to total expenses
            total += amount;

            // Add to category expenses
            if (tempCategoryExpenses.containsKey(category)) {
              tempCategoryExpenses[category] = tempCategoryExpenses[category]! + amount;
            } else {
              tempCategoryExpenses[category] = amount;
            }
          }
        }

        setState(() {
          totalExpenses = total;
          categoryExpenses = tempCategoryExpenses;
        });
      } catch (e) {
        print("Error fetching expenses: $e");
      }
    }
  }

  void _logout() async {
    setState(() {
      isLogout = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
    setState(() {
      isLogout = false;
    });
  }  void _transactions() async {
    setState(() {
      isTransaction = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacementNamed(context, '/transactions');
    setState(() {
      isTransaction = false;
    });
  }
  void _profile() async {
    setState(() {
      isProfile = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacementNamed(context, '/profile');
    setState(() {
      isProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/onboard');
      });

      return const Scaffold(
        backgroundColor: Color(0xFF9FE7F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF053F5C)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF9FE7F5),
      appBar: AppBar(
        title: const Text("Dashboard",
            style: TextStyle(color: Colors.white)
        ),
        backgroundColor: const Color(0xFF053F5C),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF9FE7F5),  // Light blue background
        child: ListView(
          padding: EdgeInsets.zero,  // Removes default padding
          children: [
            // Custom header
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E5C78), Color(0xFF429EBD), Color(0xFF053F5C)],  // Gradient from dark blue to light blue
                  begin: Alignment.topLeft,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: IntrinsicHeight(  // Adjusts height according to content
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 20,  // Larger avatar size
                      backgroundColor: Colors.white,
                      child: Icon(Icons.account_circle, size: 40, color: Color(0xFF053F5C)),
                    ),
                    const SizedBox(width: 15),  // Space between avatar and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _username ?? 'User Name',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,  // Slightly bold for the name
                            ),
                          ),
                          const SizedBox(height: 5),  // Space between name and phone number
                          Text(
                            _account_number ?? 'Phone Number',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            _bank_name ?? 'Phone Number',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 1),
            ListTile(
              leading: const Icon(Icons.payment),
              title: Row(
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (isTransaction) // Check if loading is true
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
              onTap: _transactions,
            ),
            const Divider(thickness: 1,),
            ListTile(
              leading: const Icon(Icons.person),
              title: Row(
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (isProfile) // Check if loading is true
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
              onTap: _profile,
            ),
            const Divider(thickness: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Row(
                children: [
                  const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (isLogout) // Check if loading is true
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
              onTap: _logout,
            ),
            const Divider(thickness: 1),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (_username != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Hey, $_username!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF053F5C),
                  ),
                ),
              ),
            Card(
              elevation: 4,
              color: const Color(0xFFF5F5F5),
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
                    const SizedBox(height: 5),
                    Text(
                      "₹${totalExpenses.toStringAsFixed(2)}",
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
            const SizedBox(height: 10),
            // Display the Pie Chart
            categoryExpenses.isEmpty
                ? const Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Color(0xFF1E5C78)),
              ),
            )
                : Card(
              elevation: 4,
              color: const Color(0xFF1E5C78),
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height:300,
                  child: PieChart(
                    PieChartData(
                      sections: categoryExpenses.entries.map((entry) {
                        return PieChartSectionData(
                          color: categoryColors[entry.key] ?? Colors.grey,
                          value: entry.value,
                          title: '',
                          radius: 50,
                          showTitle: false,
                        );
                      }).toList(),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display category expenses below the pie chart
            categoryExpenses.isEmpty
                ? const SizedBox()
                : Column(
              children: categoryExpenses.entries
                  .map(
                    (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: categoryColors[entry.key] ?? Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${entry.key}: ₹${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  final Map<String, Color> categoryColors = {
    'Groceries': const Color(0xFFECB762),
    'Transportation': const Color(0xFFFFE6AE),
    'Entertainment': const Color(0xFFF4BAB0),
    'Rent': const Color(0xFF7EA59B),
    'Dining Out': const Color(0xFFF47F7D),
  };
}
