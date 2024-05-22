import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drivermateuser/appinfo/appinfo.dart';
import 'package:drivermateuser/global/globalvar.dart';
import 'package:drivermateuser/models/addressmodel.dart';
import 'package:drivermateuser/models/directiondetails.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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

  static sendRequestToAPI(String apiUrl)async{
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));
    try{
      if(responseFromAPI.statusCode == 200){
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      }
      else{
        return "error";
      }
    }
    catch(errorMsg){
      return "error";
    }
  }

  static Future<String> convertGeoGraphicCoordinatesIntoHumanReadableAddress(Position position, BuildContext context)async
  {
    String humanReadableAddress = "";
    String apiGeoCodingUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
    var responsefromAPI = await sendRequestToAPI(apiGeoCodingUrl);
    if(responsefromAPI != "error"){
      humanReadableAddress = responsefromAPI["results"][0]["formatted_address"];
      print("humanReadableAddress = "+ humanReadableAddress);
      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);
    }
    else{
      print("humanReadableAddress = "+ humanReadableAddress);
    }
    return humanReadableAddress;
  }

  ///Directions API
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(LatLng source, LatLng destination)async{
    String urlDirectionsAPI = "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if(responseFromDirectionsAPI == "error"){
      return null;
    }
    DirectionDetails detailsModel = DirectionDetails();
    detailsModel.distanceTextString =  responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits =  responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString =  responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits =  responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints =  responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;

  }
  calculateFareAmount(DirectionDetails directionDetails){
    double distancePerKmAmount = 11;

    double totalDistanceTravelFareAmount = (directionDetails.distanceValueDigits!/1000) * distancePerKmAmount;

    return totalDistanceTravelFareAmount.toStringAsFixed(1); 
  }
}
