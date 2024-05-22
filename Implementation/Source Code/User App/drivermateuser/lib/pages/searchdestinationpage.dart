import 'package:drivermateuser/appinfo/appinfo.dart';
import 'package:drivermateuser/commonres/methods.dart';
import 'package:drivermateuser/global/globalvar.dart';
import 'package:drivermateuser/models/predictionmodel.dart';
import 'package:drivermateuser/widgets/predictionplaceui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({super.key});

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();
  List <PredictionModel> dropOffPredictionsPlacesList = [];

  ///Search Places Suggestions
  searchLocation(String locationName)async
  {
    if(locationName.length> 1){
      String apiPlacesUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$googleMapKey&components=country:np";
      var responseFromPlacesAPI = await Methods.sendRequestToAPI(apiPlacesUrl);
      if(responseFromPlacesAPI == "error"){
        return;
      }
      if(responseFromPlacesAPI["status"] == "OK"){
        var predictionResultInJson = responseFromPlacesAPI["predictions"];
        var predictionList = (predictionResultInJson as List).map((eachPlacePrediction) => PredictionModel.fromJson(eachPlacePrediction)).toList();
        setState(() {
          dropOffPredictionsPlacesList = predictionList;
        });

        print("predictionResultInJson=" + predictionResultInJson.toString());

      }
  
    }
  }
  @override
  Widget build(BuildContext context) {
    String userAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.humanReadableAddress ??"";
    pickUpTextEditingController.text = userAddress;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 230,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  boxShadow: 
                  [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ]
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 6,),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap:(){
                              Navigator.pop(context);
                            } , child: Icon(Icons.arrow_back,color: Colors.white,),
                            ),

                            const Center(
                              child: Text(
                                "Set Destination",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),),
                            )
                        ],
                      ),
                      const SizedBox(height: 18,),
                      //PickUp Location TextField
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/initial.png",
                            height: 16,
                            width: 16,
                          
                          ),
                          const SizedBox(width: 18,),

                          Expanded(
                            child:Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: pickUpTextEditingController,
                                  decoration: const InputDecoration(
                                    hintText: "Pickup Address",
                                    fillColor: Colors.white12,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9)
                                  ),
                                ),
                                ),
                            ), 
                            ),

                        ],
                      ),
                      const SizedBox(width: 18,),
                      //Destination Location textfield
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/final.png",
                            height: 16,
                            width: 16,
                          
                          ),
                          const SizedBox(width: 18,),

                          Expanded(
                            child:Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: destinationTextEditingController,
                                  onChanged: (inputText){
                                    searchLocation(inputText);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Destination Address",
                                    fillColor: Colors.white12,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9)
                                  ),
                                ),
                                ),
                            ), 
                            ),

                        ],
                      )
                    ],),
                  ),
                ),
            ),
            //Show suggestions for destination
            (dropOffPredictionsPlacesList.length>0) ? 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder:(context,index){
                  return Card(
                    elevation: 3,
                    child: PredictionPlaceUI(
                      predictedPlaceData: dropOffPredictionsPlacesList[index],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context,int index) => const SizedBox(height: 2,),
                itemCount: dropOffPredictionsPlacesList.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                ),
            ) : Container(),

          ],),
      ),
    );
  }
}