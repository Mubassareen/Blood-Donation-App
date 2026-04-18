import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rayan/home/home_page.dart';
import 'package:rayan/requests/all_request_page.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 2;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController bloodTypeController;
  late TextEditingController cityController;

  Map<String, dynamic>? donorData;
  Map<String, dynamic>? userData;
  List<dynamic>? historyData;

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AllRequestsPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    ageController = TextEditingController();
    weightController = TextEditingController();
    bloodTypeController = TextEditingController();
    cityController = TextEditingController();
    _loadUserAndDonorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    weightController.dispose();
    bloodTypeController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndDonorData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userData = userDoc.data();
        firstNameController.text = userData?['firstName'] ?? '';
        lastNameController.text = userData?['lastName'] ?? '';
        ageController.text = (userData?['age'] ?? '').toString();
      }
      final donorDoc = await FirebaseFirestore.instance.collection('donors').doc(uid).get();
      if (donorDoc.exists) {
        donorData = donorDoc.data();
        weightController.text = (donorData?['weight'] ?? '').toString();
        bloodTypeController.text = donorData?['bloodType'] ?? '';
        cityController.text = donorData?['city'] ?? '';
      }
      final historySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('history')
          .get();
      historyData = historySnapshot.docs.map((doc) {
        final data = doc.data();
        if (data['donationTime'] != null) {
          final timestamp = data['donationTime'];
          final time = timestamp is Timestamp ? timestamp.toDate() : DateTime.tryParse(timestamp);
          if (time != null) {
            data['donationTime'] = DateFormat('HH:mm').format(time); // Changed to 24-hour format
          }
        }
        if (data['approvedAt'] != null) {
          final approvedTimestamp = data['approvedAt'];
          final approvedTime = approvedTimestamp is Timestamp ? approvedTimestamp.toDate() : DateTime.tryParse(approvedTimestamp.toString());
          if (approvedTime != null) {
            data['approvedAt'] = DateFormat('HH:mm').format(approvedTime); // Changed to 24-hour format
          }
        }
        return data;
      }).toList();
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateDonorData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('donors').doc(uid).update({
      'weight': double.tryParse(weightController.text) ?? 0,
      'bloodType': bloodTypeController.text,
      'city': cityController.text,
    });
    _loadUserAndDonorData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Donor Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'User Details'),
            Tab(text: 'Edit'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserDetailsTab(),
          _buildEditProfileTab(),
          _buildHistoryTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.red.shade700,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Blood Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildUserDetailsTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: _boxDecoration(),
          padding: const EdgeInsets.all(20),
          child: donorData == null && userData == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.red.shade800,
                        child: Text(
                          bloodTypeController.text,
                          style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _infoTile(icon: Icons.person, label: "Name:", value: "${firstNameController.text} ${lastNameController.text}"),
                    _infoTile(icon: Icons.calendar_today, label: "Age:", value: ageController.text),
                    _infoTile(icon: Icons.monitor_weight, label: "Weight:", value: "${weightController.text} kg"),
                    _infoTile(icon: Icons.bloodtype, label: "Blood Type:", value: bloodTypeController.text),
                    _infoTile(icon: Icons.location_city, label: "City:", value: cityController.text),
                  ],
                ),
        ),
      );

  Widget _buildEditProfileTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _editableField(label: "Weight", controller: weightController, keyboardType: TextInputType.number),
            _editableField(label: "Blood Type", controller: bloodTypeController),
            _editableField(label: "City", controller: cityController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateDonorData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      );

  Widget _buildHistoryTab() => historyData == null
      ? const Center(child: CircularProgressIndicator())
      : historyData!.isEmpty
          ? const Center(child: Text('No donation history available.'))
          : ListView.builder(
              itemCount: historyData!.length,
              itemBuilder: (context, index) {
                final item = historyData![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 5, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Donation Date: ${item['donationDate']}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                Text('Time: ${item['donationTime']}',
                                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700])),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Place: ${item['donationPlace']}',
                                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700])),
                                Text('Approved At: ${item['approvedAt']}',
                                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );

  Widget _infoTile({required IconData icon, required String label, required String value}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.red.shade800, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _editableField({required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextField(
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          controller: controller,
          keyboardType: keyboardType,
        ),
      );

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      );
}