import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drivermateuser/appinfo/appinfo.dart';
import 'package:drivermateuser/authentication/login.dart';
import 'package:drivermateuser/commonres/methods.dart';
import 'package:drivermateuser/global/globalvar.dart';
import 'package:drivermateuser/global/tripvar.dart';
import 'package:drivermateuser/models/directiondetails.dart';
import 'package:drivermateuser/pages/searchdestinationpage.dart';
import 'package:drivermateuser/widgets/loadingdialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State <HomePage> createState() =>  HomePageState();
}

class  HomePageState extends State <HomePage> {
  final Completer<GoogleMapController> googleMapCompletterController =
    Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPostionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  Methods cMethods = Methods();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripdirectionDetailsInfo;
  List<LatLng> polylineCoOrdinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isDrawerOpened = true;
  String stateOfApp = "normal";

  void updateMapTheme(GoogleMapController controller){
    getJsonFileFromThemes("themes/nightstyle.json").then((value)=> setGoogleMapStyle(value, controller));
  }
  
  Future<String> getJsonFileFromThemes(String mapStylePath) async
  {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(byteData.offsetInBytes,byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller)
  {
    controller.setMapStyle(googleMapStyle);

  }
  getCurrentLiveLocationOfUser()async
  {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPostionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(currentPostionOfUser!.latitude, currentPostionOfUser!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    await Methods.convertGeoGraphicCoordinatesIntoHumanReadableAddress(currentPostionOfUser!,context);
    await getUserInfoAndCheckBlockStatus();
  }

  getUserInfoAndCheckBlockStatus()async{
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(FirebaseAuth.instance.currentUser!.uid);
    await usersRef.once().then((snap){
        if(snap.snapshot.value != null){
          if((snap.snapshot.value as Map)["blockStatus"]=="no"){
            setState(() {
              userName = (snap.snapshot.value as Map)["name"];
            });
          }
          else{
             FirebaseAuth.instance.signOut();
             Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
          cMethods.displaySnackBar("Your account has been blocked.", context);

          }
        }
        else{
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
        }
      });
  }

  displayUserRideDetailsContainer() async{
    ////draw route between pickup and drop off and directions
    await retrieveDirectionDetails();
    
    setState(() {
      searchContainerHeight = 0;
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 244;
      isDrawerOpened = false;
    });
  }

  retrieveDirectionDetails()async{
    var pickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;
    var pickupGeoGraphicCoordinates = LatLng(pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var dropOffDestinationGeoGraphicCoordinates = LatLng(dropOffDestinationLocation!.latitudePosition!, dropOffDestinationLocation.longitudePosition!);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context)=> LoadingDialog(messageText: "Getting directions..."),
    );
    
    /////Requesting Direction API
    var detailsFromDirectionAPI =  await Methods.getDirectionDetailsFromAPI(pickupGeoGraphicCoordinates, dropOffDestinationGeoGraphicCoordinates);

    setState(() {
      tripdirectionDetailsInfo = detailsFromDirectionAPI;
    });

    Navigator.pop(context);
    //draw polyline route
    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromPickUpToDestination = pointsPolyline.decodePolyline(tripdirectionDetailsInfo!.encodedPoints!);
    polylineCoOrdinates.clear();
    if(latLngPointsFromPickUpToDestination.isNotEmpty){
      latLngPointsFromPickUpToDestination.forEach((PointLatLng latLngPoint) 
    {
      polylineCoOrdinates.add(LatLng(latLngPoint.latitude, latLngPoint.longitude));

     });
    }

     polylineSet.clear();
     setState(() {
       Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: Colors.green,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
       );
       polylineSet.add(polyline);
     });
    //fit polyline in the map
     LatLngBounds boundsLatLng;
     if(pickupGeoGraphicCoordinates.latitude > dropOffDestinationGeoGraphicCoordinates.latitude && pickupGeoGraphicCoordinates.longitude>dropOffDestinationGeoGraphicCoordinates.longitude)
     {
      boundsLatLng = LatLngBounds(
        southwest: dropOffDestinationGeoGraphicCoordinates, 
        northeast: pickupGeoGraphicCoordinates);

     }
     else if(pickupGeoGraphicCoordinates.longitude > dropOffDestinationGeoGraphicCoordinates.longitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(pickupGeoGraphicCoordinates.latitude,dropOffDestinationGeoGraphicCoordinates.longitude),
       northeast:  LatLng(dropOffDestinationGeoGraphicCoordinates.latitude, pickupGeoGraphicCoordinates.longitude )
       );
     }
     else if(pickupGeoGraphicCoordinates.latitude> dropOffDestinationGeoGraphicCoordinates.latitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(dropOffDestinationGeoGraphicCoordinates.latitude, pickupGeoGraphicCoordinates.longitude ) ,
        northeast: LatLng(pickupGeoGraphicCoordinates.latitude,dropOffDestinationGeoGraphicCoordinates.longitude),
        );
     }
     else{
      boundsLatLng = LatLngBounds(
        southwest: pickupGeoGraphicCoordinates, 
        northeast: dropOffDestinationGeoGraphicCoordinates,
        );
     }
     controllerGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));
    ///Adding Markers
     Marker pickUpPointMarker = Marker(
      markerId: MarkerId("pickUpPointMarkerID"),
      position: pickupGeoGraphicCoordinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: pickUpLocation.placeName, snippet: "PickUp Location"),
     );

     Marker dropOffDestinationPointMarker = Marker(
      markerId: MarkerId("dropOffDestinationPointMarkerID"),
      position: dropOffDestinationGeoGraphicCoordinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: dropOffDestinationLocation.placeName, snippet: "Destination Location"),
     );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOffDestinationPointMarker);
    });
    ///adding Circles
    Circle pickUpPointCircle = Circle(
      circleId: const CircleId('pickupCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: pickupGeoGraphicCoordinates,
      fillColor: Colors.red,
      );
    Circle dropOffDestinationPointCircle = Circle(
      circleId: const CircleId('dropOffDestinationCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: dropOffDestinationGeoGraphicCoordinates,
      fillColor: Colors.green,
      );

      setState(() {
        circleSet.add(pickUpPointCircle);
        circleSet.add(dropOffDestinationPointCircle);
      });
  }

  resetAppNow(){
    setState(() {
      polylineCoOrdinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight = 276;
      bottomMapPadding = 300;
      isDrawerOpened = true;

      nameDriver = '';
      photoDriver = '';
      phoneNumberDriver = '';
      requestTimeOutDriver = 20;
      status = '';
      carDetailsDriver = '';
      tripsStatusDisplay = 'Driver is Arriving';

    });
  }

  cancelRideRequest(){
    //remove ride request from database
    setState(() {
      stateOfApp = "normal";
    });
  }

  displayRequestContainer(){
    setState(() {
      rideDetailsContainerHeight=0;
      requestContainerHeight = 220;
      bottomMapPadding = 200;
      isDrawerOpened = true;
    });

    //send ride request
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 295,
        color: Colors.white,
        child: Drawer(
          backgroundColor: Colors.white10,
          child: ListView(
            children: [
              //header
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                        ),
                      const SizedBox(width: 16,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4,),
                          const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),

                        ],
                      )

                    ],),
                ),
              ),
            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(height: 10,),

            //body
            ListTile(
              leading: IconButton(
                onPressed: (){},
                icon: const Icon(Icons.info, color: Colors.grey,) ,),
                title: const Text("About", style: TextStyle(color: Colors.grey),),
            ),
            GestureDetector(
              onTap: (){
                FirebaseAuth.instance.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
              },
              child: ListTile(
                leading: IconButton(
                  onPressed: (){
                    
                  },
                  icon: const Icon(Icons.logout, color: Colors.grey,) ,),
                  title: const Text("Logout", style: TextStyle(color: Colors.grey),),
              ),
            ),
            
            ],
            )
          ),
        ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController){
              controllerGoogleMap = mapController;
              updateMapTheme(controllerGoogleMap!);
              googleMapCompletterController.complete(controllerGoogleMap);
              setState(() {
                bottomMapPadding = 300;
              });

              getCurrentLiveLocationOfUser();
            },

          ),
          //Drawer Button
          Positioned(
            top: 42,
            left: 19,
            child: GestureDetector(
              onTap: (){
                if(isDrawerOpened == true){
                  sKey.currentState!.openDrawer();
                }
                else{
                  resetAppNow();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const
                  [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ]
                ),
                child:  CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(
                    isDrawerOpened == true? Icons.menu: Icons.close,
                    color: Colors.black87,
                    ),
                ),
              ),
              ),

          ),
          //Search icon
          Positioned(
            left: 0,
            right: 0,
            bottom: -80,
            child: Container(
              height: searchContainerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed:() async{
                      var responseFromSearchPage = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchDestinationPage()));
                      if(responseFromSearchPage == "placeSelected"){
                        displayUserRideDetailsContainer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 25,
                      ),
                      ),
                   ElevatedButton(
                    onPressed:(){

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 25,
                      ),
                      ),
                    ElevatedButton(
                      onPressed:(){

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                      ),
                      child: const Icon(
                        Icons.work,
                        color: Colors.white,
                        size: 25,
                        ),
                        ),
                ],
              ),
            )
          ),
          //ride details container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: rideDetailsContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white12,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(.7, .7),
                  ),
                ]

              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18) ,
                child: Column(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: SizedBox(
                        height: 190,
                        child: Card(
                          elevation: 10,
                          child: Container(
                            width: MediaQuery.of(context).size.width * .70,
                            color: Colors.black45,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8,right: 8),
                                    child: Row(
                                      
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (tripdirectionDetailsInfo != null)? tripdirectionDetailsInfo!.distanceTextString!:"",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      
                                        ),
                                      
                                        Text(
                                          (tripdirectionDetailsInfo != null)? tripdirectionDetailsInfo!.durationTextString!:"",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      
                                        ),
                                                                    ]),
                                  ),
                                      GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            stateOfApp = "requesting";
                                          });

                                          displayRequestContainer();

                                          //get nearest drivers

                                          //search driver until trip is accepted
                                        },
                                        child: Image.asset(
                                          "assets/images/avatarman.png",
                                          height: 122,
                                          width: 122,
                                        ),
                                      ),
                                    
                                      Text(
                                        (tripdirectionDetailsInfo != null)?"Rs ${(cMethods.calculateFareAmount(tripdirectionDetailsInfo!)).toString()}" : "",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    
                                      ),
                                    ],
                                  
                            
                              ),
                            ),
                          ),
                          ),
                      
                      )
                      ,)
                  ],
                ),
                ),
                
            ),
          ),

          //request container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: requestContainerHeight,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 12,),

                    SizedBox(
                      width: 200,
                      child: LoadingAnimationWidget.flickr(
                        leftDotColor: Colors.greenAccent,
                        rightDotColor: Colors.pinkAccent,
                        size: 50,
                      ) ,
                    ),

                    const SizedBox(height: 20,),
                    GestureDetector(
                      onTap: (){
                        resetAppNow();
                        cancelRideRequest();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1, color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    )
                  ],
                  )
            ),
            ),
          )
        ],
      )
    );
  }
}