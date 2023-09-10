import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/assistants/geofire_assistant.dart';
import 'package:users_app/mainScreens/rate_doctor_screen.dart';
import 'package:users_app/mainScreens/select_nearest_active_doctor_screen.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';

import '../models/active_nearby_available_doctors.dart';
import '../widgets/my_drawer.dart';
import '../widgets/pay_fare_amount_dialog.dart';

class MainScreen extends StatefulWidget
{
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {

  final Completer<GoogleMapController> _controllerGoogleMap =
  Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponseFromDoctorContainerHeight = 0;
  double assignedDoctorInfoContainerHeight = 0;

  bool requestPositionInfo = true;
  Position? userCurrentPosition;
  var geoLocator = Geolocator();


  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "Name";
  String userEmail = "Email";
  String userVisitRequestStatus = "";

  bool openNavigationDrawer = true;

  bool activeNearbyDoctorKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List <ActiveNearbyAvailableDoctors> onlineNearbyAvailableDoctorsList = [];

  DatabaseReference? referenceVisitRequest;
  String doctorVisitStatus = "Doctor is Coming";

  StreamSubscription<DatabaseEvent>? treatmentVisitRequestInfoStreamSubscription;

  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(
        target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));
    // ignore: use_build_context_synchronously
    String humanReadableAddress = await AssistantMethods
        .searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeofireListener();
    AssistantMethods.readTreatmentsKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  saveVisitRequestInformation() {
    //1.save the visit request information

    referenceVisitRequest =
        FirebaseDatabase.instance.ref().child("All visit Requests").push();

    var originLocation = Provider
        .of<AppInfo>(context, listen: false)
        .userPickUpLocation;

    Map originLocationMap = {

      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "originAddress": originLocation.locationName,
      "doctorId": "waiting",
      "userPhone": userModelCurrentInfo!.phone,
    };
    referenceVisitRequest!.set(userInformationMap);

    treatmentVisitRequestInfoStreamSubscription = referenceVisitRequest!.onValue.listen((eventSnap)
    async {
      if(eventSnap.snapshot.value == null)
      {
        return;
      }

      if((eventSnap.snapshot.value as Map)["service_details"] != null)
      {
        setState(() {
          doctorServiceDetails = (eventSnap.snapshot.value as Map)["service_details"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["doctorPhone"] != null)
      {
        setState(() {
          doctorPhone = (eventSnap.snapshot.value as Map)["doctorPhone"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["doctorName"] != null)
      {
        setState(() {
          doctorName = (eventSnap.snapshot.value as Map)["doctorName"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["status"] != null)
      {
        userVisitRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
      }

      if((eventSnap.snapshot.value as Map)["doctorLocation"] != null)
      {
        double doctorCurrentPositionLat = double.parse((eventSnap.snapshot.value as Map)["doctorLocation"]["latitude"].toString());
        double doctorCurrentPositionLng = double.parse((eventSnap.snapshot.value as Map)["doctorLocation"]["longitude"].toString());

        LatLng doctorCurrentPositionLatLng = LatLng(doctorCurrentPositionLat, doctorCurrentPositionLng);

        //status = accepted
        if(userVisitRequestStatus == "accepted")
        {
          updateArrivalTimeToUserPickupLocation(doctorCurrentPositionLatLng);
        }

        //status = arrived
        if(userVisitRequestStatus == "arrived")
        {
          setState(() {
            doctorVisitStatus = "Doctor has Arrived";
          });
        }

        //status = treatment
        //

        if(userVisitRequestStatus == "ended"){

          if((eventSnap.snapshot.value as Map)["base_price"] != null){
              double treatmentAmount = double.parse((eventSnap.snapshot.value as Map)["base_price"].toString());
              var response = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext c) => PayFareAmountDialog(
                  treatmentAmount: treatmentAmount,
                ),
              );

              if(response == "cashPaid")
              {
                //user can rate the doctor now
                if((eventSnap.snapshot.value as Map)["doctorId"] != null)
                {
                  String assignedDoctorId = (eventSnap.snapshot.value as Map)["doctorId"].toString();

                  Navigator.push(context, MaterialPageRoute(builder: (c)=> RateDoctorScreen(
                    assignedDoctorId: assignedDoctorId,
                  )));

                  referenceVisitRequest!.onDisconnect();
                  treatmentVisitRequestInfoStreamSubscription!.cancel();
                }
              }

          }
        }

      }
    });


    onlineNearbyAvailableDoctorsList =
        GeoFireAssistant.activeNearbyAvailableDoctorsList;
    searchNearestOnlineDoctors();
  }

  updateArrivalTimeToUserPickupLocation(doctorCurrentPositionLatLng) async {
    if(requestPositionInfo == true){
      requestPositionInfo = false;
      LatLng userPickupPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(doctorCurrentPositionLatLng, userPickupPosition);
      if(directionDetailsInfo == null){
        return;
      }
      setState(() {
        print(doctorCurrentPositionLatLng + userPickupPosition);
        doctorVisitStatus = "Doctor is coming in ${directionDetailsInfo.duration_text}";
      });

      requestPositionInfo = true;

    }
  }

  searchNearestOnlineDoctors() async {
    if (onlineNearbyAvailableDoctorsList.isEmpty) {
      //we have to cancel the visit request
      referenceVisitRequest!.remove();

      Fluttertoast.showToast(msg: "No online Nearest doctor Available.");

      Fluttertoast.showToast(msg: "Search again after sometime.");
      Future.delayed(const Duration(milliseconds: 4000), () {
        SystemNavigator.pop();
      });

      return;
    }

    await retrieveOnlineDoctorsInformation(onlineNearbyAvailableDoctorsList);

    var response = await Navigator.push(context, MaterialPageRoute(
        builder: (c) => SelectNearestActiveDoctorsScreen(
            referenceVisitRequest: referenceVisitRequest)));

    if (response == "doctorChosen") {
      FirebaseDatabase.instance.ref().child("doctors")
          .child(chosenDoctorId)
          .once()
          .then((snap) {
        if (snap.snapshot.value != null) {
          //send notification to specific doctor
          sendNotificationToDoctorNow(chosenDoctorId);

          //Display Waiting Response UI from a Doctor
          showWaitingResponseFromDoctorUI();

          //Response from a Doctor
          FirebaseDatabase.instance.ref()
              .child("doctors")
              .child(chosenDoctorId!)
              .child("newVisitStatus")
              .onValue.listen((eventSnapshot)
          {
            //1. doctor has cancel the visitRequest :: Push Notification
            // (newRideStatus = idle)
            if(eventSnapshot.snapshot.value == "idle")
            {
              Fluttertoast.showToast(msg: "The doctor has cancelled your request. Please choose another one.");

              Future.delayed(const Duration(milliseconds: 3000), ()
              {
                Fluttertoast.showToast(msg: "Please Restart App Now.");

                SystemNavigator.pop();
              });
            }

            //2. doctor has accept the rideRequest :: Push Notification
            // (newRideStatus = accepted)
            if(eventSnapshot.snapshot.value == "Accepted")
            {
              //design and display ui for displaying assigned doctor information
              showUIForAssignedDoctorInfo();
            }


          });
          //response

          //1. doctor can cancel the ride request Push notification


          //2. accept the request
        } else {
          Fluttertoast.showToast(msg: "This Doctor don't exist.");
        }
      });
    }
  }

  showUIForAssignedDoctorInfo(){
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDoctorContainerHeight = 0;
      assignedDoctorInfoContainerHeight = 240;
    });

  }

  showWaitingResponseFromDoctorUI(){
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDoctorContainerHeight = 220;
    });
  }

  sendNotificationToDoctorNow(String chosenDoctorId) {
    //set visit request id in database
    FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(chosenDoctorId)
        .child("newVisitStatus")
        .set(referenceVisitRequest!.key);

    FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(chosenDoctorId).child("token").once().then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();
//sending notification
        AssistantMethods.sendNotificationToDoctorNow(
            deviceRegistrationToken, referenceVisitRequest!.key.toString(),
            context);
        Fluttertoast.showToast(msg: "Notification sent successfully");
      } else {
        Fluttertoast.showToast(msg: "Please choose another Service!");
        return;
      }
    });
    //automate the push notification


  }

  retrieveOnlineDoctorsInformation(List onlineNearestDoctorsList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("doctors");

    for (int i = 0; i < onlineNearestDoctorsList.length; i++) {
      await ref.child(onlineNearestDoctorsList[i].doctorId.toString())
          .once()
          .then((dataSnapshot) {
        var doctorInfoKey = dataSnapshot.snapshot.value;
        dList.add(doctorInfoKey);
        print("Doctor key information = " + dList.toString());
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    createActiveNearByDoctorIconMarker();

    return Scaffold(
      key: sKey,

      drawer: MyDrawer(
        name: userName,
        email: userEmail,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            child: GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _kGooglePlex,
              markers: markersSet,
              circles: circlesSet,


              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                //for black theme of google maps
                //blackThemeGoogleMap();
                setState(() {
                  bottomPaddingOfMap = 170;
                });
                locateUserPosition();
              },
            ),
          ),
          //custom hamburger button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                if (openNavigationDrawer) {
                  sKey.currentState!.openDrawer();
                }
                else {
                  //restart-refresh-minimize app programmatically
                  SystemNavigator.pop();
                }
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.menu,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          Positioned(
            top: 650,
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18),
                  child: Column(
                    children: [
                      //ui location
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined, color: Colors
                              .blue,),
                          const SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Call At",
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 18),
                              ),
                              Text(
                                Provider
                                    .of<AppInfo>(context)
                                    .userPickUpLocation != null
                                    ? (Provider
                                    .of<AppInfo>(context)
                                    .userPickUpLocation!
                                    .locationName!).substring(0, 30) + ("...") :
                                "can't get location",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),


                      //const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.black,
                      ),

                      const SizedBox(height: 16.0),

                      ElevatedButton(
                        child: const Text(
                          "Request a Medical Service",
                        ),
                        onPressed: () {
                          saveVisitRequestInformation();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            textStyle: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold)
                        ),

                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ui for waiting response
          Positioned  (
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: waitingResponseFromDoctorContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'Waiting for Response\nfrom Doctor',
                        duration: const Duration(seconds: 6),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(fontSize: 28.0, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      ScaleAnimatedText(
                        'Please wait...',
                        duration: const Duration(seconds: 10),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(fontSize: 28.0, color: Colors.white, fontFamily: 'Canterbury'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ui for displaying assigned doctor information
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: assignedDoctorInfoContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //status of ride
                    Center(
                      child: Text(
                        doctorVisitStatus,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.white,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    //doctor vehicle details
                    Text(
                      doctorServiceDetails,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(
                      height: 2.0,
                    ),

                    //doctor name
                    Text(
                      doctorName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.white,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    //call doctor button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: ()
                        {

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: const Text(
                          "Call doctor",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  initializeGeofireListener() {
    Geofire.initialize("activeDoctors");
    Geofire.queryAtLocation(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 5)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];
        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']
        switch (callBack) {

          case Geofire.onKeyEntered: // whenever any doctor becomes online
            ActiveNearbyAvailableDoctors activeNearbyAvailableDoctor = ActiveNearbyAvailableDoctors();
            activeNearbyAvailableDoctor.locationLatitude = map['latitude'];
            activeNearbyAvailableDoctor.locationLongitude = map['longitude'];
            activeNearbyAvailableDoctor.doctorId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDoctorsList.add(
                activeNearbyAvailableDoctor);
             if (activeNearbyDoctorKeysLoaded == true) {
                displayActiveDoctorsOnUsersMap();
             }
            break;
          case Geofire.onKeyExited: // whenever any doctor becomes offline
            GeoFireAssistant.deleteOfflineDoctorFromList(map['key']);
            displayActiveDoctorsOnUsersMap();
            break;
          case Geofire.onKeyMoved: //whenever doctor moves
            ActiveNearbyAvailableDoctors activeNearbyAvailableDoctor = ActiveNearbyAvailableDoctors();
            activeNearbyAvailableDoctor.locationLatitude = map['latitude'];
            activeNearbyAvailableDoctor.locationLongitude = map['longitude'];
            activeNearbyAvailableDoctor.doctorId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDoctorLocation(activeNearbyAvailableDoctor);
            displayActiveDoctorsOnUsersMap();
            break;
        //display active doctors on users map
          case Geofire.onGeoQueryReady:
            activeNearbyDoctorKeysLoaded = true;
            displayActiveDoctorsOnUsersMap();

            break;
        }
      }
      setState(() {});
    });
  }

  displayActiveDoctorsOnUsersMap(){
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> doctorsMarkerSet = <Marker>{};


      for(ActiveNearbyAvailableDoctors eachDoctor in GeoFireAssistant.activeNearbyAvailableDoctorsList)
      {
        LatLng eachDoctorActivePosition = LatLng(eachDoctor.locationLatitude!, eachDoctor.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("doctors"+ eachDoctor.doctorId!),
          position: eachDoctorActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        doctorsMarkerSet.add(marker);
      }
      setState(() {
        markersSet = doctorsMarkerSet;
      });
    });
  }

  createActiveNearByDoctorIconMarker()
  {
    if(activeNearbyIcon == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/red_plus.png").then((value)
      {
        activeNearbyIcon = value;
      });
    }
  }
}
