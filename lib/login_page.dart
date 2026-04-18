import 'package:flutter/material.dart';
import 'register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rayan/admin/admin_page.dart'; // adjust the path if needed

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController _uname = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  Future<void> signIN() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _uname.text.trim(),
        password: _pass.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw FirebaseAuthException(code: 'user-not-found', message: 'User not found');

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String role = userDoc.get('role');

      if (role == 'admin') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AdminPage()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      }

    } on FirebaseAuthException catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    }
  }

  @override
  void dispose() {
    _uname.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 245, 245),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                'Welcome!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: const Color.fromARGB(255, 160, 17, 17),
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _uname,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: const Color.fromARGB(255, 134, 11, 11)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 134, 11, 11)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: const Color.fromARGB(255, 134, 11, 11)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 134, 11, 11)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 134, 11, 11),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: signIN,
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not Registered?', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterPage()));
                    },
                    child: Text(
                      'Register Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 160, 17, 17),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
