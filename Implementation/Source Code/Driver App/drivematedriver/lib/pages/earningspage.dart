import 'package:flutter/material.dart';
class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Earning",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),) ,),
    );
  }
}