import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  double totalExpenses = 0;
  Map<String, double> categoryExpenses = {};
  String? _username;
  String? _account_number;
  String? _bank_name;
  bool isProfile = false;
  bool isTransaction = false;
  bool isLogout = false;
  bool isDarkMode = false;
  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();
  final List<Color> _bgColors = [
    Color(0xFF1E5C78),
    Color(0xFF1E5C78),
    Color(0xFF1E5C78),
  ];

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

            total += amount;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
  }

  void _transactions() async {
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

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          username: _username,
          totalExpenses: totalExpenses,
          categoryExpenses: categoryExpenses,
          flipCardKey: _flipCardKey,
        );
      case 1:
        return FutureInsightScreen();
      case 2:
        return NotificationScreen();
      default:
        return HomeScreen(
          username: _username,
          totalExpenses: totalExpenses,
          categoryExpenses: categoryExpenses,
          flipCardKey: _flipCardKey,
        );
    }
  }

  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode
          ? ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
      )
          : ThemeData.light().copyWith(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
      ),
      home:Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF053F5C),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu_rounded, size: 28),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Open the drawer
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, size: 28), // Logout icon
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF9FE7F5),
                    title: const Text(
                      'Are you sure you want to log out ?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _logout,
                        child: const Text('Logout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF053F5C),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: _toggleDarkMode,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,  // Removes default padding
            children: [
              // Custom header
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E5C78),  // Gradient from dark blue to light blue
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
            ],
          ),
        ),
        body: _getScreen(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFF1E5C78),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          selectedLabelStyle: const  TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.grid_view_rounded,
                color: _selectedIndex == 0 ? Color(0xFFF27F0C) : Colors.white,  // Change color based on selection
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.bar_chart_rounded,
                color: _selectedIndex == 1 ? Color(0xFFF27F0C) : Colors.white,  // Change color based on selection
              ),
              label: 'Future Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications_none_outlined,
                color: _selectedIndex == 2 ? Color(0xFFF27F0C) : Colors.white,  // Change color based on selection
              ),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String? username;
  final double totalExpenses;
  final Map<String, double> categoryExpenses;
  final GlobalKey<FlipCardState> flipCardKey;

  HomeScreen({
    Key? key,
    this.username,
    required this.totalExpenses,
    required this.categoryExpenses,
    required this.flipCardKey,
  }) : super(key: key);

  final Map<String, Color> categoryColors = {
    'Groceries': const Color(0xFFECB762),
    'Transportation': const Color(0xFFFFE6AE),
    'Entertainment': const Color(0xFFF4BAB0),
    'Rent': const Color(0xFF7EA59B),
    'Dining Out': const Color(0xFFF47F7D),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          const SizedBox(height: 5),
          if (username != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Hey, $username!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Card(
            elevation: 8,
            color: const Color(0xFFF5F5F5),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                    child: Text(
                      "Overall Expenditure",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF053F5C),
                      ),
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
          categoryExpenses.isEmpty
              ? const Center(
            child: Text(
              "No data available",
              style: TextStyle(color: Color(0xFF1E5C78)),
            ),
          )
              : FlipCard(
            key: flipCardKey,
            direction: FlipDirection.HORIZONTAL,
            front: GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 4,
                color: const Color(0xFF1E5C78),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: categoryExpenses.entries.map((entry) {
                              return PieChartSectionData(
                                color: categoryColors[entry.key] ?? Colors.grey,
                                value: entry.value,
                                title: '',
                                radius: 40,
                                showTitle: false,
                              );
                            }).toList(),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 4,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                          onPressed: () {
                            flipCardKey.currentState?.toggleCard();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            back: GestureDetector(
              onTap: () {
                flipCardKey.currentState?.toggleCard();
              },
              child: Card(
                elevation: 4,
                color: const Color(0xFF1E5C78),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Category-wise Expenditure",
                          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 160,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: categoryColors.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        color: entry.value,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "${entry.key}",
                                        style: const TextStyle(color: Colors.white, fontSize: 17),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: categoryExpenses.entries.map((entry) {
              return Card(
                color: categoryColors[entry.key] ?? Colors.grey, // Use the category color for each entry
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Color(0xFF053F5C)),
                  title: Text(
                    "${entry.key}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF053F5C),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "₹${entry.value.toStringAsFixed(2)}", // Show the category amount here as well
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class FutureInsightScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Future Insights Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Notifications Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
