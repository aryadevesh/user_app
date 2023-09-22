import 'package:firebase_database/firebase_database.dart';

class TreatmentsHistoryModel
{
  String? time;
  String? originAddress;
  String? status;
  String? base_price;
  String? service_details;
  String? doctorName;

  TreatmentsHistoryModel({
    this.time,
    this.originAddress,
    this.status,
    this.service_details,
    this.doctorName,
    this.base_price,
  });

  TreatmentsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot)
  {
    time = (dataSnapshot.value as Map)["time"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    //destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    status = (dataSnapshot.value as Map)["status"];
    base_price = (dataSnapshot.value as Map)["base_price"];
    service_details = (dataSnapshot.value as Map)["service_details"];
    doctorName = (dataSnapshot.value as Map)["doctorName"];
  }
}