import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rayan/donor/donor_profile_page.dart';

class BecomeDonorPage extends StatefulWidget {
  const BecomeDonorPage({super.key});

  @override
  State<BecomeDonorPage> createState() => _BecomeDonorPageState();
}

class _BecomeDonorPageState extends State<BecomeDonorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  String? _selectedCity;

  final List<String> _cities = [
    'Muscat', 'Salalah', 'Sohar', 'Nizwa', 'Sur',
    'Ibri', 'Buraimi', 'Rustaq', 'Seeb', 'Mutrah',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _ageController.text = (data['age'] ?? '').toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  bool _isEligible(int age, double weight) {
    return age >= 17 && age <= 65 && weight >= 50;
  }

  Future<void> _saveDonorData() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      try {
        final age = int.parse(_ageController.text);
        final weight = double.parse(_weightController.text);
        final bloodType = _bloodTypeController.text.trim();
        final city = _selectedCity;

        // Save to donors collection
        final donorData = {
          'uid': currentUser.uid,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'age': age,
          'weight': weight,
          'bloodType': bloodType,
          'city': city,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        };

        // Save to both donors collection and update user document
        final batch = FirebaseFirestore.instance.batch();
        
        // Set donor document
        final donorRef = FirebaseFirestore.instance
            .collection('donors')
            .doc(currentUser.uid);
        batch.set(donorRef, donorData, SetOptions(merge: true));

        // Update user document to mark as donor
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid);
        batch.update(userRef, {
          'isDonor': true,
          'bloodType': bloodType,
          'lastDonorUpdate': FieldValue.serverTimestamp(),
        });

        await batch.commit();

        if (context.mounted) {
          _showResultDialog(
            isEligible: _isEligible(age, weight),
            context: context,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving data: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _showResultDialog({required bool isEligible, required BuildContext context}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEligible ? "✅ Eligible" : "⚠️ Not Eligible"),
        content: Text(
          isEligible 
              ? "Great news!🎉 You're eligible to donate blood 👏— and we've saved your details. \nThank you for making a difference!🩸❤️"
              : "🚫 Unfortunately, you're not eligible to donate blood right now.🙏 Thanks for checking — stay healthy and try again later!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isEligible) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DonorProfilePage()),
                );
              }
            },
            child: Text(isEligible ? "Go to Profile" : "OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaSection(String title, List<String> items, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 10),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              Text(e, style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canDonate = [
      "Be generally fit and well",
      "Be aged between 17 and 65",
      "Weigh 50kg or more",
      "Have suitable veins",
      "Meet all donor eligibility criteria"
    ];

    final cannotDonate = [
      "Had most types of cancer",
      "Have heart conditions",
      "Received blood after 1 Jan 1980",
      "Tested positive for HIV",
      "Had an organ transplant",
      "Are a hepatitis B or C carrier",
      "Injected non-prescribed drugs",
      "Other medical conditions may apply"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Become a Donor",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCriteriaSection(
                "🩸 Who Can Donate Blood", canDonate, Colors.green.shade700),
            _buildCriteriaSection(
                "🚫 Who Can't Donate Blood", cannotDonate, Colors.red.shade700),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            const Text(
              "Fill the fields below to check your eligibility:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "First Name",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lastNameController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Last Name",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Weight (kg)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter weight";
                      final weight = double.tryParse(value);
                      if (weight == null) return "Enter valid weight";
                      if (weight < 30 || weight > 200) return "Enter realistic weight";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _bloodTypeController,
                    decoration: const InputDecoration(
                      labelText: "Blood Type (e.g., A+)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter blood type";
                      if (!RegExp(r'^(A|B|AB|O)[+-]$').hasMatch(value.toUpperCase())) {
                        return "Enter valid blood type (e.g., A+, O-)";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    items: _cities
                        .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCity = value),
                    decoration: const InputDecoration(
                      labelText: "City",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null ? "Please select your city" : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveDonorData,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        "Save & Check Eligibility",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}