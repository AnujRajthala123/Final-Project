import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class Methods{
  connectivityCheck(BuildContext context) async{
    var connectionResult = await Connectivity().checkConnectivity();
    print(connectionResult);
    if(!connectionResult.contains(ConnectivityResult.mobile) && !connectionResult.contains(ConnectivityResult.wifi)){
      if(!context.mounted) return;
      displaySnackBar('Internet is not available. Try Again!!', context);

    }

  }
  displaySnackBar(String message, BuildContext context){
    var snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
