import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyBCObH-gmhjuBNojtUPcbS-5-BCU9Z80d0",
    appId: "1:981044840392:android:39e74cc25ee7f5693a62fd",
    messagingSenderId: "981044840392",
    projectId: "rayan-26e10",
    storageBucket: "rayan-26e10.firebasestorage.app",
  ));
  
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(), // Your Home widget
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}