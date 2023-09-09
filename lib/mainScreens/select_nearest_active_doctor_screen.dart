import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import 'package:users_app/global/global.dart';


class SelectNearestActiveDoctorsScreen extends StatefulWidget
{
  DatabaseReference? referenceVisitRequest;

  SelectNearestActiveDoctorsScreen({super.key, this.referenceVisitRequest});
  @override
  _SelectNearestActiveDoctorsScreenState createState() => _SelectNearestActiveDoctorsScreenState();
}



class _SelectNearestActiveDoctorsScreenState extends State<SelectNearestActiveDoctorsScreen>
{

  @override
  void dispose()  {
    super.dispose();
    dList = [] ;

  }
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

  @override

  Widget build(BuildContext context)
  {
    dList = checkDuplicates(dList);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Nearest Online Doctors",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close, color: Colors.black
          ),
          onPressed: ()
          {
            //delete/remove the ride request from database
            widget.referenceVisitRequest!.remove();
            Fluttertoast.showToast(msg: "Restart App");
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.builder(

        itemCount: dList.length,
        itemBuilder: (BuildContext context, int index)
        {
          return GestureDetector(
            onTap:()
            {
              setState(() {
                chosenDoctorId = dList[index]["id"].toString();
              });
              Navigator.pop(context, "doctorChosen");
            },
            child: Card(
              color: Colors.lightBlueAccent,
              elevation: 3,
              shadowColor: Colors.blue,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Image.asset(
                    "images/" + dList[index]["service_details"]["service_type"].toString() + ".png",
                    width: 70,
                  ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      dList[index]["name"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      dList[index]["service_details"]["institution_name"],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    SmoothStarRating(
                      rating: 4.2,
                      color: Colors.black,
                      borderColor: Colors.black,
                      allowHalfRating: true,
                      starCount: 5,
                      size: 15,
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rs."+ dList[index]["service_details"]["base_price"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
