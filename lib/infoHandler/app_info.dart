import 'package:flutter/cupertino.dart';
import 'package:users_app/models/directions.dart';

class AppInfo extends ChangeNotifier
{
  Directions? userPickUpLocation;
  int countTotalTreatments = 0;

  void updatePickUpLocationAddress(Directions userPickUpAddress)
  {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }
  updateOverAllTreatmentsCounter(int overAllTreatmentsCounter){

  }

}