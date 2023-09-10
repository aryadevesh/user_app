import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //active doctors list
String chosenDoctorId  = "";
String userPickupAddress = "";
String doctorServiceDetails = "";
String doctorName = "";
String doctorPhone = "";
double countRatingStars=0.0;
String titleStarsRating="";