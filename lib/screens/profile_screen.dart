import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:start1/screens/dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  String? _email;
  String? _phoneNumber;
  String? _dob;
  String? _gender;
  String? _address;
  String? _bankName;
  String? _accountNumber;
  int? _age;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();

  String? _selectedGender;
  String? _selectedBank;
  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _bankOptions = [
    'Axis Bank',
    'Bank of Baroda',
    'HDFC Bank',
    'ICICI Bank',
    'IDBI Bank',
    'Indusland Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
    'State Bank of India',
    'Union Bank of India'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch user profile details from Firestore
  void _fetchUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Safely access the user.uid
      print("User UID: ${user.uid}");

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc['username'];
            _email = user.email;
            _phoneNumber = userDoc['phone_number'] ?? '';
            _dob = userDoc['dob'] ?? '';
            _gender = userDoc['sex'] ?? '';
            _address = userDoc['address'] ?? '';
            _bankName = userDoc['bank_name'] ?? '';
            _accountNumber = userDoc['account_number'] ?? '';
            _age = userDoc['age'] ?? 0;

            // Initialize the controllers with fetched data
            _usernameController.text = _username ?? '';
            _emailController.text = _email ?? '';
            _phoneNumberController.text = _phoneNumber ?? '';
            _dobController.text = _dob ?? '';
            _addressController.text = _address ?? '';
            _ageController.text = (_age ?? 0).toString();
            _accountNumberController.text = _accountNumber ?? '';
            _selectedGender = _gender;
            _selectedBank = _bankName;
          });
        } else {
          print("User document does not exist");
        }
      } catch (e) {
        print("Error fetching user profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load profile data")),
        );
      }
    } else {
      print("No user is signed in.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user is signed in")),
      );
    }

  }

  // Update user profile in Firestore
  void _updateUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'username': _usernameController.text,
          'email': _emailController.text,
          'phone_number': _phoneNumberController.text,
          'dob': _dobController.text,
          'sex': _selectedGender,
          'address': _addressController.text,
          'bank_name': _selectedBank,
          'account_number': _accountNumberController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      } catch (e) {
        print("Error updating user profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile")),
        );
      }
    }
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  // Open DatePicker dialog
  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime(currentDate.year + 1);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Profile", style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()),);
          },
        ),
        backgroundColor: const Color(0xFF053F5C),
      ),
      body: SingleChildScrollView( // Add scrolling
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_username != null) ...[
                Text('Update your Profile $_username', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
              ],
              // TextFields to edit details
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                  filled: true,fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                  filled: true,
                  fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                  filled: true,
                  fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Date of Birth (DD/MM/YYYY)', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                  filled: true,
                  fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Gender',
                  filled: true,
                  fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                  filled: true,
                  fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                  filled: true,
                  fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedBank,
                items: _bankOptions.map((String bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBank = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Bank Name', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                  filled: true,
                  fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _accountNumberController,
                decoration: InputDecoration(
                  labelText: 'Account Number', labelStyle: const TextStyle(color: Color(0xFF053F5C),),
                  filled: true,
                  fillColor: Color(0xFF429EBD).withOpacity(0.2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1E5C78), width: 2,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF429EBD), width: 2,),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Center(
                child: ElevatedButton(
                  onPressed: _updateUserProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: const Color(0xFF053F5C),
                  ),
                  child: const Text(
                    '   Save Profile   ',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
