import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rayan/requests/all_request_page.dart';

class AddRequestPage extends StatefulWidget {
  const AddRequestPage({super.key});

  @override
  _AddRequestPageState createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  // Controllers
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _caseOfPatientController =
      TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _requiredAmountController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Dropdown selections
  String _selectedBloodGroup = 'A+';
  String _selectedCity = 'Muscat';
  String _selectedState = 'Muscat';
  DateTime _requiredDate = DateTime.now();

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  final List<String> cities = [
    'Muscat',
    'Salalah',
    'Sohar',
    'Nizwa',
    'Sur',
    'Ibri',
    'Buraimi',
    'Rustaq',
    'Seeb',
    'Mutrah',
  ];

  final List<String> states = ['Muscat', 'Dhofar', 'Al Batinah'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Blood Request", style: TextStyle(color:Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Fill all the fields to request required blood, we will help you find the donor quickly',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _buildInputField(
              controller: _patientNameController,
              label: 'Patient Name',
              icon: Icons.person,
            ),
            _buildInputField(
              controller: _contactPersonController,
              label: 'Contact Person',
              icon: Icons.contact_phone,
            ),
            _buildDropdownField(
              label: 'Select Blood Group',
              value: _selectedBloodGroup,
              items: bloodGroups,
              onChanged:
                  (value) => setState(() => _selectedBloodGroup = value!),
            ),
            _buildDropdownField(
              label: 'Select City',
              value: _selectedCity,
              items: cities,
              onChanged: (value) => setState(() => _selectedCity = value!),
            ),
            _buildDropdownField(
              label: 'Select State',
              value: _selectedState,
              items: states,
              onChanged: (value) => setState(() => _selectedState = value!),
            ),
            _buildInputField(
              controller: _hospitalController,
              label: 'Hospital',
              icon: Icons.local_hospital,
            ),
            _buildDateField(
              label: 'Required Date',
              selectedDate: _requiredDate,
              onDateSelected: (date) => setState(() => _requiredDate = date),
            ),
            _buildInputField(
              controller: _caseOfPatientController,
              label: 'Case of the Patient',
              icon: Icons.medical_services,
            ),
            _buildInputField(
              controller: _requiredAmountController,
              label: 'Required Amount (in units)',
              icon: Icons.bloodtype,
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              controller: _phoneController,
              label: 'Phone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You must be logged in to make a request',
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await FirebaseFirestore.instance.collection('requests').add(
                      {
                        'uid': user.uid,
                        'patientName': _patientNameController.text.trim(),
                        'contactPerson': _contactPersonController.text.trim(),
                        'bloodGroup': _selectedBloodGroup,
                        'city': _selectedCity,
                        'state': _selectedState,
                        'hospital': _hospitalController.text.trim(),
                        'requiredDate': _requiredDate.toIso8601String(),
                        'caseOfPatient': _caseOfPatientController.text.trim(),
                        'requiredAmount': _requiredAmountController.text.trim(),
                        'phone': _phoneController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      },
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request submitted successfully')),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllRequestsPage(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit request: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.red),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.arrow_drop_down, color: Colors.red),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items:
            items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: TextEditingController(
          text: "${selectedDate.toLocal()}".split(' ')[0],
        ),
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today, color: Colors.red),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            onDateSelected(pickedDate);
          }
        },
      ),
    );
  }
}
