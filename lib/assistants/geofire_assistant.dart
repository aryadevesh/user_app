

import '../models/active_nearby_available_doctors.dart';

class GeoFireAssistant
{
  static List<ActiveNearbyAvailableDoctors> activeNearbyAvailableDoctorsList = [];

  static void deleteOfflineDoctorFromList(String doctorId)
  {
    int indexNumber = activeNearbyAvailableDoctorsList.indexWhere((element) => element.doctorId == doctorId);
    activeNearbyAvailableDoctorsList.removeAt(indexNumber);
  }

  static void updateActiveNearbyAvailableDoctorLocation(ActiveNearbyAvailableDoctors doctorWhoMove)
  {
    int indexNumber = activeNearbyAvailableDoctorsList.indexWhere((element) => element.doctorId == doctorWhoMove.doctorId);

    activeNearbyAvailableDoctorsList[indexNumber].locationLatitude = doctorWhoMove.locationLatitude;
    activeNearbyAvailableDoctorsList[indexNumber].locationLongitude = doctorWhoMove.locationLongitude;
  }
}