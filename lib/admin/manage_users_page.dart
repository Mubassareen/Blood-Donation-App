import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  Future<void> _assignAdmin(String uid, String fullName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': 'admin',
      });

      debugPrint('User role updated to admin');

      // Show a snackbar for confirmation
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$fullName is now an admin.')));
    } catch (e) {
      debugPrint('Error assigning admin role: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteUser(String uid, String fullName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete User'),
            content: Text('Are you sure you want to delete $fullName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fullName deleted successfully.')),
        );
      } catch (e) {
        debugPrint('Error deleting user: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Users',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children:
                snapshot.data!.docs.map((doc) {
                  final user = doc.data() as Map<String, dynamic>;
                  final userId = doc.id;
                  final role = user['role'] ?? 'user';

                  final fullName =
                      '${user['firstName'] ?? 'No name'} ${user['lastName'] ?? ''}';

                  return Card(
                    child: ListTile(
                      title: Text(fullName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${user['email'] ?? 'No email'}'),
                          Text('Age: ${user['age'] ?? 'No age'}'),
                          Text('Role: ${user['role'] ?? 'No role'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (role != 'admin')
                            Tooltip(
                              message: "Assign Admin",
                              child: IconButton(
                                icon: const Icon(
                                  Icons.security,
                                  color: Colors.green,
                                ),
                                onPressed: () => _assignAdmin(userId, fullName),
                              ),
                            ),
                          Tooltip(
                            message: "Delete User",
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(userId, fullName),
                            ),
                          ),
                        ],
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
