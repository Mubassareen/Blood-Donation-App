import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 181, 17, 6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 5,
          color: const Color.fromARGB(255, 255, 245, 238),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: const [
                Text(
                  'About Our Blood Donation App',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 201, 5, 5),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Our Blood Donation App is a mobile application designed to help donors and patients connect easily. It allows users to request and donate blood, manage donor profiles, track donation history, and participate in blood donation events across the region.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 24),
                Text(
                  'Authors:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Mubassareen Noorulhasan - 2020293141\n2. Mahzabee Noorulhasan - 2019293186',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                Text(
                  'Course Title:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Mobile Application Development',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                Text(
                  'Course Lecturer:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Mr. Ayyad Al Haj',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                Text(
                  'Institution:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'University of Applied Sciences and Technology - Sohar (UATS)',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
