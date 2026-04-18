import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rayan/home/events.dart';
import 'package:rayan/login_page.dart';
import 'package:rayan/requests/add_request_page.dart';
import 'package:rayan/requests/all_request_page.dart';
import 'package:rayan/donor/become_donor_page.dart';
import 'package:rayan/bloodbank.dart';
import 'package:rayan/donor/donor_profile_page.dart';
import 'package:rayan/donor/donor_search_page.dart'; // Create this page
import 'package:rayan/about.dart';           // Create and import this


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  
Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage())); // Redirect to login page
  }
  void _onNavTap(int index) {
    setState(() {
      _currentIndex = 0;
    });

    if (index == 0) {
      // Stay on HomePage
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AllRequestsPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DonorProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = "John Doe"; // Replace with actual user name

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Blood Donation App",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
      ),
      drawer: Drawer(
  backgroundColor: Colors.white,
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: const Color.fromARGB(255, 87, 81, 81)),
        child: Text(
          'Menu',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      ListTile(
        leading: Icon(Icons.info),
        title: Text('About'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutPage()),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Profile'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DonorProfilePage()),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text('Logout'),
        onTap: () {
          _logout(context);// Add your logout logic here
          Navigator.pop(context); // Close the drawer
        },
      ),
    ],
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $userName",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                ],
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          _cityController.text.isNotEmpty
                              ? _cityController.text
                              : null,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_city,
                          color: Colors.red,
                        ),
                        hintText: 'Select City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      items:
                          [
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
                              ]
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _cityController.text = value;
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          _bloodTypeController.text.isNotEmpty
                              ? _bloodTypeController.text
                              : null,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.bloodtype, color: Colors.red),
                        hintText: 'Select Blood Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      items:
                          ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _bloodTypeController.text = value;
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      final city = _cityController.text.trim();
                      final bloodType = _bloodTypeController.text.trim();

                      if (city.isEmpty || bloodType.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select both city and blood type',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DonorSearchPage(
                                city: city,
                                bloodType: bloodType,
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.search, color: Colors.white,),
                    label: Text("Find", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 2.5,
              children: [
                _gridItem(Icons.add, "Add Request", context),
                _gridItem(Icons.favorite, "Become Donor", context),
                _gridItem(Icons.event, "Events", context),
                _gridItem(Icons.local_hospital, "Blood Bank", context),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.red.shade700,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Blood Requests',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _gridItem(IconData icon, String label, BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (label == "Add Request") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddRequestPage()),
            );
          } else if (label == "Become Donor") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BecomeDonorPage()),
            );
          } else if (label == "Blood Bank") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BloodBankPage()),
            );
          }else if (label == "Events") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventsPage()),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.red.shade700, size: 50),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
