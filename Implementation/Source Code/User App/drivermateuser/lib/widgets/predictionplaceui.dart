import 'package:drivermateuser/appinfo/appinfo.dart';
import 'package:drivermateuser/commonres/methods.dart';
import 'package:drivermateuser/global/globalvar.dart';
import 'package:drivermateuser/models/addressmodel.dart';
import 'package:drivermateuser/models/predictionmodel.dart';
import 'package:drivermateuser/widgets/loadingdialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PredictionPlaceUI extends StatefulWidget {
  PredictionModel? predictedPlaceData;
  PredictionPlaceUI({super.key, this.predictedPlaceData,});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  /////////Place Details
  fetchClickedPlaceDetails(String placeID)async{
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context)=> LoadingDialog(messageText: "Getting details..."),
    );

    String urlPlaceDetailsAPI = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$googleMapKey";
    var responseFromPlaceDetailsAPI = await Methods.sendRequestToAPI(urlPlaceDetailsAPI);

    Navigator.pop(context);

    if(responseFromPlaceDetailsAPI == "error"){
      return;
    }
    if(responseFromPlaceDetailsAPI["status"] == "OK"){
      AddressModel dropOffLocation = AddressModel();
      dropOffLocation.placeName = responseFromPlaceDetailsAPI["result"]["name"];
      dropOffLocation.latitudePosition = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lat"];
      dropOffLocation.longitudePosition = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lng"];
      dropOffLocation.placeID = placeID;

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);
      Navigator.pop(context, "placeSelected");


    }
  }
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        fetchClickedPlaceDetails(widget.predictedPlaceData!.placeid.toString());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: Container(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              children: [
                const Icon(
                  Icons.share_location,
                  color: Colors.grey,
                ),
                const SizedBox(width: 13,),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictedPlaceData!.maintext.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                         ),
                      ),
                      const SizedBox(height: 3,),
                      Text(
                        widget.predictedPlaceData!.secondarytext.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                         ),
                      )
                    ],)
                ),

              
              ],
            ),
            const SizedBox(height: 10,),
          ],),
      ),
      );
  }
}