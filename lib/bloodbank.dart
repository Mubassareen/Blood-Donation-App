import 'package:flutter/material.dart';

class BloodBankPage extends StatefulWidget {
  const BloodBankPage({super.key});

  @override
  _BloodBankPageState createState() => _BloodBankPageState();
}

class _BloodBankPageState extends State<BloodBankPage> {
  String? selectedState;
  String? selectedCity;

  // List of states (Governorates) in Oman
  List<String> states = [
    "Muscat", "Dhofar", 'Musandam', 'Buraymi', 'Dakhiliyah', 'North Batinah',
    'South Batinah', 'South Sharqiyah', 'North Sharqiyah', 'Dhahirah', 'Wusta'
  ];

  // Cities for each state
  Map<String, List<String>> cities = {
    'Muscat': ['Bawshar', 'Darsait', 'Al Khuwair', 'Al Khoudh'],
    'Dhofar': ['Salalah'],
    'Musandam': ['Khasab'],
    'Buraymi': ['Al Buraimi'],
    'Dakhiliyah': ['Nizwa', 'Samail'],
    'North Batinah': ['Sohar'],
    'South Batinah': ['Rustaq'],
    'South Sharqiyah': ['Sur', 'Masirah'],
    'North Sharqiyah': ['Ibra'],
    'Dhahirah': ['Ibri'],
    'Wusta': ['Duqm'],
  };

  // Blood bank data for each city
  Map<String, Map<String, List<Map<String, String>>>> bloodBankData = {
    'Muscat': {
      'Bawshar': [
        {
          'name': 'Central Blood Bank',
          'address': 'Muscat St.',
          'phone': '+968 1234 5678',
          'hours': '8 AM - 4 PM'
        },
        {
          'name': 'Royal Hospital Blood Bank',
          'address': 'Royal Hospital, Muscat',
          'phone': '+968 2345 6789',
          'hours': '9 AM - 5 PM'
        },
      ],
      'Darsait': [
        {
          'name': 'KIMSHEALTH Blood Bank (Darsait)',
          'address': 'Darsait Area, Muscat',
          'phone': '+968 3456 7890',
          'hours': '8 AM - 4 PM'
        },
      ],
      'Al Khuwair': [
        {
          'name': 'KIMSHEALTH Blood Bank (Al Khuwair)',
          'address': 'Al Khuwair, Muscat',
          'phone': '+968 4567 8901',
          'hours': '9 AM - 5 PM'
        },
      ],
      'Al Khoudh': [
        {
          'name': 'SQUH Blood Bank',
          'address': 'Al Khoudh, Muscat',
          'phone': '+968 5678 9012',
          'hours': '8 AM - 4 PM'
        },
      ],
    },
    'Dhofar': {
      'Salalah': [
        {
          'name': 'Salalah Regional Blood Bank',
          'address': 'Health Center Rd.',
          'phone': '+968 6789 0123',
          'hours': '9 AM - 5 PM'
        },
      ],
    },
    'Musandam': {
      'Khasab': [
        {
          'name': 'Khasab Blood Bank',
          'address': 'Khasab, Musandam',
          'phone': '+968 7890 1234',
          'hours': '8 AM - 4 PM'
        },
      ],
    },
    'Buraymi': {
      'Al Buraimi': [
        {
          'name': 'Al Buraimi Blood Bank',
          'address': 'Al Buraimi, Oman',
          'phone': '+968 8901 2345',
          'hours': '9 AM - 5 PM'
        },
      ],
    },
    'Dakhiliyah': {
      'Nizwa': [
        {
          'name': 'Nizwa Blood Bank',
          'address': 'Nizwa Hospital, Blood Bank Dept.',
          'phone': '+968 9012 3456',
          'hours': '7 AM - 3 PM'
        },
      ],
      'Samail': [
        {
          'name': 'Samail Blood Bank',
          'address': 'Samail Hospital, Blood Bank Dept.',
          'phone': '+968 2345 6789',
          'hours': '8 AM - 4 PM'
        },
      ],
    },
    'North Batinah': {
      'Sohar': [
        {
          'name': 'Sohar Blood Bank',
          'address': 'Sohar Hospital, Blood Bank Dept.',
          'phone': '+968 3456 7890',
          'hours': '8 AM - 4 PM'
        },
      ],
    },
    'South Batinah': {
      'Rustaq': [
        {
          'name': 'Rustaq Blood Bank',
          'address': 'Rustaq Hospital, Blood Bank Dept.',
          'phone': '+968 4567 8901',
          'hours': '9 AM - 5 PM'
        },
      ],
    },
    'South Sharqiyah': {
      'Sur': [
        {
          'name': 'Sur Blood Bank',
          'address': 'Sur Hospital, Blood Bank Dept.',
          'phone': '+968 5678 9012',
          'hours': '8 AM - 4 PM'
        },
      ],
      'Masirah': [
        {
          'name': 'Masirah Blood Bank',
          'address': 'Masirah Hospital, Blood Bank Dept.',
          'phone': '+968 6789 0123',
          'hours': '9 AM - 5 PM'
        },
      ],
    },
    'North Sharqiyah': {
      'Ibra': [
        {
          'name': 'Ibra Blood Bank',
          'address': 'Ibra Hospital, Blood Bank Dept.',
          'phone': '+968 7890 1234',
          'hours': '8 AM - 4 PM'
        },
      ],
    },
    'Dhahirah': {
      'Ibri': [
        {
          'name': 'Ibri Blood Bank',
          'address': 'Ibri Hospital, Blood Bank Dept.',
          'phone': '+968 8901 2345',
          'hours': '9 AM - 5 PM'
        },
      ],
    },
    'Wusta': {
      'Duqm': [
        {
          'name': 'Duqm Blood Bank',
          'address': 'Duqm Hospital, Blood Bank Dept.',
          'phone': '+968 9012 3456',
          'hours': '8 AM - 4 PM'
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = (selectedState != null &&
                selectedCity != null &&
                bloodBankData[selectedState]?[selectedCity] != null)
        ? bloodBankData[selectedState]![selectedCity]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Bank Info'),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedState,
              onChanged: (String? newValue) {
                setState(() {
                  selectedState = newValue;
                  selectedCity = null;
                });
              },
              decoration: InputDecoration(labelText: "Select State"),
              items: states
                  .map((state) => DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            if (selectedState != null)
              DropdownButtonFormField<String>(
                value: selectedCity,
                onChanged: (String? newCity) {
                  setState(() {
                    selectedCity = newCity;
                  });
                },
                decoration: InputDecoration(labelText: "Select City"),
                items: cities[selectedState]!
                    .map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
              ),
            SizedBox(height: 20),
            if (info != null)
              ...info.map((bloodBank) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blood Bank: ${bloodBank['name']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('📍 Address: ${bloodBank['address']}'),
                        SizedBox(height: 5),
                        Text('📞 Phone: ${bloodBank['phone']}'),
                        SizedBox(height: 5),
                        Text('🕒 Hours: ${bloodBank['hours']}'),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
