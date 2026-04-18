import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorSearchPage extends StatefulWidget {
  final String city;
  final String bloodType;

  const DonorSearchPage({
    super.key,
    required this.city,
    required this.bloodType,
  });

  @override
  State<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends State<DonorSearchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _donorProfiles = [];
  bool _isLoading = true;

  void _callDonor(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch dialer')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDonors();
  }

  Future<void> _fetchDonors() async {
    try {
      // Step 1: Get donors that match city & blood type
      final donorQuery = await _firestore
          .collection('donors')
          .where('city', isEqualTo: widget.city)
          .where('bloodType', isEqualTo: widget.bloodType)
          .get();

      final List<Map<String, dynamic>> donorList = [];

      for (var donorDoc in donorQuery.docs) {
        final donorData = donorDoc.data();
        final uid = donorData['uid'];

        // Step 2: Get user details from users collection
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final userData = userDoc.data();

        if (userData != null) {
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          final fullName = (firstName + ' ' + lastName).trim();

          donorList.add({
            'name': fullName.isNotEmpty ? fullName : 'N/A',
            'phone': userData['phone'] ?? 'N/A',
            'bloodType': donorData['bloodType'],
            'city': donorData['city'],
          });
        }
      }

      setState(() {
        _donorProfiles = donorList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching donors: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matching Donors'),
        backgroundColor: Colors.red.shade700,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _donorProfiles.isEmpty
              ? Center(child: Text('No donors found for your criteria.'))
              : ListView.builder(
                  itemCount: _donorProfiles.length,
                  itemBuilder: (context, index) {
                    final donor = _donorProfiles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person, color: Colors.red),
                        title: Text(donor['name']),
                        subtitle: Text(
                          'Blood Type: ${donor['bloodType']} • City: ${donor['city']}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.phone, color: Colors.green),
                          onPressed: () {
                            _callDonor(donor['phone']);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
