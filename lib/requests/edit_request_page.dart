import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditRequestPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> existingData;

  const EditRequestPage({
    super.key,
    required this.docId,
    required this.existingData,
  });

  @override
  State<EditRequestPage> createState() => _EditRequestPageState();
}

class _EditRequestPageState extends State<EditRequestPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _patientNameController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _cityController;
  late TextEditingController _hospitalController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _patientNameController = TextEditingController(text: widget.existingData['patientName']);
    _bloodGroupController = TextEditingController(text: widget.existingData['bloodGroup']);
    _cityController = TextEditingController(text: widget.existingData['city']);
    _hospitalController = TextEditingController(text: widget.existingData['hospital']);
    final timestamp = widget.existingData['requiredDate'] as Timestamp?;
    _selectedDate = timestamp?.toDate();
  }

  Future<void> _updateRequest() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      await FirebaseFirestore.instance.collection('requests').doc(widget.docId).update({
        'patientName': _patientNameController.text.trim(),
        'bloodGroup': _bloodGroupController.text.trim(),
        'city': _cityController.text.trim(),
        'hospital': _hospitalController.text.trim(),
        'requiredDate': Timestamp.fromDate(_selectedDate!),
        'updatedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request updated successfully!')),
      );

      Navigator.pop(context); // Go back to AllRequestsPage
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _bloodGroupController.dispose();
    _cityController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Blood Request", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _bloodGroupController,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(labelText: 'Hospital'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(_selectedDate == null
                    ? "Pick Required Date"
                    : "Required Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateRequest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                child: const Text("Update Request", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
