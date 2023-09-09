
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/models/user_model.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import 'package:http/http.dart ' as http;

class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async
  {

    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress="";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response.")
    {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress ;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async
  {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Error Occurred, Failed. No Response.")
    {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    // directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    //
    // directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    // directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    //
    // directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    // directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }
  static void readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users").child(currentFirebaseUser!.uid);

    userRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    }
    );
  }
  static sendNotificationToDoctorNow(String deviceRegistrationToken, String userVisitRequestId, context) async{

    //var destinationAddress = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };
    Map bodyNotification = {
      "body":"Hello Doctor, You have a new visit request",//at $destinationAddress,
      "title":"New Treatment Request"
    };
    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status":"done",
      "visitRequestId":userVisitRequestId,
    };
    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };
    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }

  static void readTreatmentsKeysForOnlineUser(context)
  {
    FirebaseDatabase.instance.ref()
        .child("All Visit Requests")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo!.name)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        Map keysTreatmentsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTreatmentsCounter = keysTreatmentsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTreatmentsCounter(overAllTreatmentsCounter);

        //share trips keys with Provider
        List<String> treatmentsKeysList = [];
        keysTreatmentsId.forEach((key, value)
        {
          treatmentsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTreatmentsKeys(treatmentsKeysList);

        //get trips keys data - read trips complete information
        readTreatmentsHistoryInformation(context);
      }
    });
  }

  static void readTreatmentsHistoryInformation(context)
  {
    var treatmentsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTreatmentsKeysList;

    for(String eachKey in treatmentsAllKeys)
    {
      FirebaseDatabase.instance.ref()
          .child("All Visit Requests")
          .child(eachKey)
          .once()
          .then((snap)
      {
        var eachTreatmentHistory = TreatmentsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"] == "ended")
        {
          //update-add each history to OverAllTrips History Data List
          Provider.of<AppInfo>(context, listen: false).updateOverAllTreatmentsHistoryInformation(eachTreatmentHistory);
        }
      });
    }
  }


}