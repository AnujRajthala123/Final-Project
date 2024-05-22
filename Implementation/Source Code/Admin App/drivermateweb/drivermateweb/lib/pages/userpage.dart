import 'package:drivermateweb/methods/commonmethods.dart';
import 'package:drivermateweb/widgets/usersdatalist.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  static const String id = "\webpageUsers";
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  CommonMethods cMethods = CommonMethods();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Manage Users",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
              ),
              const SizedBox(
                height: 18,
              ),

              Row(
                children: [
                    cMethods.header(2,"USER ID"),
                    cMethods.header(1,"USER NAME"),
                    cMethods.header(1,"EMAIL"),
                    cMethods.header(1,"PHONE"),
                    cMethods.header(1,"ACTION"),
                ],),
                //database data
                UsersDataList(),
            ]
          ) ,),
      ),
    );
  }
}