import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rayan/donor/donor_profile_page.dart';
import 'package:rayan/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllRequestsPage extends StatefulWidget {
  const AllRequestsPage({super.key});

  @override
  State<AllRequestsPage> createState() => _AllRequestsPageState();
}

class _AllRequestsPageState extends State<AllRequestsPage> {
  int _currentIndex = 1;
  final currentUser = FirebaseAuth.instance.currentUser;

  void _onNavTap(int index) {
  if (_currentIndex == index) return; // Prevent unnecessary actions

  setState(() {
    _currentIndex = index;
  });

  if (index == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else if (index == 1) {
    // Stay on AllRequestsPage
  } else if (index == 2) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DonorProfilePage()),
    );
  }
}


  // Function to build the request card
  Widget _buildRequestCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade700,
          child: Text(
            data['bloodGroup'] ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(data['patientName'] ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hospital: ${data['hospital'] ?? 'N/A'}"),
            Text("City: ${data['city'] ?? 'N/A'}"),
            Text("Phone: ${data['phone'] ?? 'N/A'}"),
            Text(
              "Date Needed: ${(data['requiredDate'] ?? '').toString().split('T').first}",
            ),
          ],
        ),
        isThreeLine: true,
        trailing:
            currentUser?.uid == data['uid']
                ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editRequest(doc); // Call the edit function
                    } else if (value == 'delete') {
                      _deleteRequest(doc.id); // Call delete function
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                )
                : null,
      ),
    );
  }

  // Function to edit a request
  void _editRequest(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Controllers to pre-fill the fields with existing data
    final TextEditingController patientNameController = TextEditingController(
      text: data['patientName'],
    );
    final TextEditingController hospitalController = TextEditingController(
      text: data['hospital'],
    );
    final TextEditingController cityController = TextEditingController(
      text: data['city'],
    );
    final TextEditingController phoneController = TextEditingController(
      text: data['phone'],
    );
    final TextEditingController requiredDateController = TextEditingController(
      text: data['requiredDate']?.toString(),
    );
    final TextEditingController bloodGroupController = TextEditingController(
      text: data['bloodGroup'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Request'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Name Field
                TextField(
                  controller: patientNameController,
                  decoration: const InputDecoration(labelText: 'Patient Name'),
                ),
                // Hospital Field
                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(labelText: 'Hospital'),
                ),
                // City Field
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                // Phone Field
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                // Required Date Field
                TextField(
                  controller: requiredDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date Needed (YYYY-MM-DD)',
                  ),
                ),
                // Blood Group Field
                TextField(
                  controller: bloodGroupController,
                  decoration: const InputDecoration(labelText: 'Blood Group'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Show a loading indicator while updating
                showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  // Ensure the requiredDate is in the correct format, and if needed, parse it
                  String requiredDate = requiredDateController.text;

                  // Update the request in Firestore
                  await FirebaseFirestore.instance
                      .collection('requests')
                      .doc(doc.id)
                      .update({
                        'patientName': patientNameController.text,
                        'hospital': hospitalController.text,
                        'city': cityController.text,
                        'phone': phoneController.text,
                        'requiredDate':
                            requiredDate, // Make sure the format is correct
                        'bloodGroup': bloodGroupController.text,
                      });

                  // Close the dialog after updating
                  Navigator.of(context).pop(); // Close the loading dialog
                  Navigator.of(context).pop(); // Close the edit dialog
                } catch (error) {
                  Navigator.of(context).pop(); // Close the loading dialog
                  print("Failed to update request: $error");
                  // Optionally show an error message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update request: $error')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a request
  void _deleteRequest(String requestId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Request'),
          content: const Text('Are you sure you want to delete this request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('requests')
                    .doc(requestId)
                    .delete()
                    .then((_) {
                      Navigator.of(context).pop(); // Close dialog after delete
                    })
                    .catchError((error) {
                      // Handle any errors here
                      print("Failed to delete request: $error");
                    });
              },
              child: const Text('Delete'),
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
          "All Blood Requests",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('requests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No blood requests available."));
          }

          final allRequests = snapshot.data!.docs;
          final yourRequests =
              allRequests
                  .where((doc) => doc['uid'] == currentUser?.uid)
                  .toList();
          final otherRequests =
              allRequests
                  .where((doc) => doc['uid'] != currentUser?.uid)
                  .toList();

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              if (yourRequests.isNotEmpty) ...[
                const Text(
                  "Your Requests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...yourRequests.map((doc) => _buildRequestCard(doc)),
                const SizedBox(height: 20),
              ],
              if (otherRequests.isNotEmpty) ...[
                const Text(
                  "Other Requests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...otherRequests.map((doc) => _buildRequestCard(doc)),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.red.shade700,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Blood Requests',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
