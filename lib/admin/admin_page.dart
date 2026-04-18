import 'package:flutter/material.dart';
import 'package:rayan/admin/manage_users_page.dart';
import 'package:rayan/admin/add_event_page.dart';
import 'package:rayan/admin/approve_donations_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for logout
import 'package:rayan/login_page.dart'; // Import your login page for redirection

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  // Method to log out the user
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage())); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 181, 17, 6),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Ensure it centers the content
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Wrap(
                spacing: 20, // Space between cards
                runSpacing: 20, // Space between rows of cards
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Manage Users',
                    icon: Icons.people,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ManageUsersPage()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Add Events',
                    icon: Icons.event,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddEventPage()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Approve Donations',
                    icon: Icons.check_circle_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ApproveDonationsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Logout button at the bottom center
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 70),
                backgroundColor: Colors.transparent, // Set a transparent background for the gradient effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                side: BorderSide(color: Colors.yellow, width: 2), // Yellow border
              ).copyWith(
                elevation: WidgetStateProperty.all(5), // Add a slight elevation
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 212, 42), // Light yellow shade
                      Color.fromARGB(255, 237, 136, 21), // Deeper yellow-orange
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
                    ),
                  ),
                ),
              ),
              onPressed: () {
                _logout(context); // Call the logout function
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white, // Background color to white
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    Gradient gradient = const LinearGradient(
      colors: [
        Color.fromARGB(255, 237, 136, 21),
        Color.fromARGB(255, 181, 17, 3),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200, // Fixed width for each card
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Space between icon and title
          children: [
            Icon(
              icon,
              color: textColor,
              size: 60, // Larger size for the icon
            ),
            const SizedBox(height: 10), // Space between icon and title
            Text(
              title,
              style: TextStyle(
                fontSize: 16, // Adjusted font size for the title
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
