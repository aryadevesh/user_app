import 'package:flutter/cupertino.dart';
import 'package:users_app/models/directions.dart';

import '../models/treatments_history_model.dart';

class AppInfo extends ChangeNotifier
{
  Directions? userPickUpLocation;
  int countTotalTreatments = 0;
  List<String> historyTreatmentsKeysList=[];
  List<TreatmentsHistoryModel> allTreatmentsHistoryInformationList = [];

  checkDuplicates(List<dynamic> dList) {
    List<dynamic> uniqueList = [];
    for (int i = 0; i < dList.length; i++) {
      bool isDuplicate = false;
      for (int j = i + 1; j < dList.length; j++) {
        if (dList[i]["id"].toString() ==
            dList[j]["id"].toString()) {
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) {
        uniqueList.add(dList[i]);
      }
    }
    return uniqueList;
  }


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
    checkDuplicates(allTreatmentsHistoryInformationList);
    notifyListeners();
  }
}