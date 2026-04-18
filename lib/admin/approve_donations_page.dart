import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveDonationsPage extends StatelessWidget {
  const ApproveDonationsPage({super.key});

  void addDonationToHistory(BuildContext context, String userId, String date, String time, String place) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('history')
          .add({
        'donationDate': date,
        'donationTime': time,
        'donationPlace': place,
        'approvedAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'donationCount': FieldValue.increment(1)});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation approved successfully!')),
      );
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving donation: $e')),
      );
    }
  }

  void showDonationPopup(BuildContext context, String userId) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final placeController = TextEditingController();

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    }

    Future<void> pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        timeController.text = picked.format(context);
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Enter Donation Details'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    onTap: pickDate,
                    decoration: const InputDecoration(labelText: 'Donation Date'),
                    validator: (val) => val == null || val.isEmpty ? 'Select a date' : null,
                  ),
                  TextFormField(
                    controller: timeController,
                    readOnly: true,
                    onTap: pickTime,
                    decoration: const InputDecoration(labelText: 'Donation Time'),
                    validator: (val) => val == null || val.isEmpty ? 'Select a time' : null,
                  ),
                  TextFormField(
                    controller: placeController,
                    decoration: const InputDecoration(labelText: 'Donation Place'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter a place' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  addDonationToHistory(
                    context,
                    userId,
                    dateController.text,
                    timeController.text,
                    placeController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Approve Donation'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Approve Donations',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Sans-serif',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 181, 17, 6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final user = doc.data() as Map<String, dynamic>;
              final userId = doc.id;
              final donationCount = user['donationCount'] ?? 0;
              final fullName = "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();

              return Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('User: $fullName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user['email'] ?? 'No Email'}'),
                      Text('Total Donations: $donationCount'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => showDonationPopup(context, userId),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve'),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
