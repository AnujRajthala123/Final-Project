import 'package:drivermateweb/dashboard/sidenavigationdrawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCvF_h3xCkGmkm_vsYa3i_yPmgyLgOXLoM",
        authDomain: "drivermate-59883.firebaseapp.com",
        databaseURL: "https://drivermate-59883-default-rtdb.firebaseio.com",
        projectId: "drivermate-59883",
        storageBucket: "drivermate-59883.appspot.com",
        messagingSenderId: "240307656540",
        appId: "1:240307656540:web:1411639bc9d9f3c3681399",
        measurementId: "G-MZZP6THP4Q")
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SideNavigationDrawer(),
    );
  }
}

