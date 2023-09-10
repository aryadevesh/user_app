import 'package:flutter/cupertino.dart';
import 'package:users_app/models/directions.dart';

import '../models/treatments_history_model.dart';

class AppInfo extends ChangeNotifier
{
  Directions? userPickUpLocation;
  int countTotalTreatments = 0;
  List<String> historyTreatmentsKeysList=[];
  List<TreatmentsHistoryModel> allTreatmentsHistoryInformationList = [];
  void updatePickUpLocationAddress(Directions userPickUpAddress)
  {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }
  updateOverAllTreatmentsCounter(int overAllTreatmentsCounter){
    countTotalTreatments = overAllTreatmentsCounter;
    notifyListeners();
  }

  updateOverAllTreatmentsKeys(List<String> treatmentsKeysList){
    historyTreatmentsKeysList = treatmentsKeysList;
    notifyListeners();
  }
  updateOverAllTreatmentsHistoryInformation(eachTreatmentHistory) {
    allTreatmentsHistoryInformationList.add(eachTreatmentHistory);
    notifyListeners();
  }
}