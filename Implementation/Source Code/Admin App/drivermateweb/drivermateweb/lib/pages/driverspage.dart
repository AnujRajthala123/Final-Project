import 'package:drivermateweb/methods/commonmethods.dart';
import 'package:drivermateweb/widgets/driversdatalist.dart';
import 'package:flutter/material.dart';

class DriversPage extends StatefulWidget {
  static const String id = "\webpageDrivers";
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  CommonMethods cMethods = CommonMethods();
  // Widget header(int headerflexValue, String headertitle){
  //   return Expanded(
  //     flex: headerflexValue,
  //     child: Container(
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.black),
  //         color: Colors.orange[700],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: Text(
  //           headertitle,
  //           style: const TextStyle(
  //             color: Colors.white,
  //           ),
  //           ),),
  //     ),
  //   );
  // }
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
                  "Manage Drivers",
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
                    cMethods.header(2,"DRIVER ID"),
                    cMethods.header(1,"PICTURE"),
                    cMethods.header(1,"NAME"),
                    cMethods.header(1,"PHONE"),
                    cMethods.header(2,"TOTAL EARNINGS"),
                    cMethods.header(1,"ACTION"),
                ],),
              DriversDataList(),
            ],
          ) ,),
      ),
    );
  }
}