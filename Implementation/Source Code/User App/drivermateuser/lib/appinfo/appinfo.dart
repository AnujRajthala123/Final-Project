import 'package:drivermateuser/models/addressmodel.dart';
import 'package:flutter/material.dart';

class AppInfo extends ChangeNotifier{
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  void updatePickUpLocation(AddressModel pickUpModel){
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDropOffLocation(AddressModel dropOffModel){
    dropOffLocation = dropOffModel;
    notifyListeners();
  }
}