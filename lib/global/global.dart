import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //active doctors list
String chosenDoctorId  = "";
String userPickupAddress = "";
String cloudMessagingServerToken = "key=AAAAVpNA7Dk:APA91bERdc42mXl6gQDYRIRAQsdpjci9-cLewVyMGw2k7KZIr34YTx7ZeATSJ-cRMNbVpgH2HOxsIXEQLTzIYr3fbnRislRf4fD2_hfl4Dj_I-3Vu3aSoF93ph5pWihDNBe0rm8_gnpF";
String doctorServiceDetails = "";
String doctorName = "";
String doctorPhone = "";
double countRatingStars=0.0;
String titleStarsRating="";