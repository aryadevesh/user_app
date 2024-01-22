import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users_app/assistants/common_methods.dart';
import 'package:users_app/authentication/login_screen.dart';

import 'package:users_app/mainScreens/main_screen.dart';
import 'package:flutter/material.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{
  CommonMethods cMethods = CommonMethods();

  startTimer() {
    fAuth.currentUser != null
        ? AssistantMethods.readCurrentOnlineUserInfo()
        : null;
    Timer(const Duration(seconds: 1), () async
    {
      // Navigator.push(context, MaterialPageRoute(builder: (c)=>  MainScreen()));
      if (fAuth.currentUser == null) {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }

      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child(
          "users").child(fAuth.currentUser!.uid);
      usersRef.once().then((snap) {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => const MainScreen()));
        }
        else {
          FirebaseAuth.instance.signOut();
          Fluttertoast.showToast(
            msg: "You are blocked so, Please contact admin: aryadevesh78@gmail.com",
            toastLength: Toast.LENGTH_LONG,
          );
          //cMethods.displaySnackBar("You are blocked so, Please contact admin: aryadevesh78@gmail.com", context);
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => LoginScreen()));
        }
        // send user to home screen
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/logo.png"),

            const SizedBox(height: 10,),

            const Text(
              "Medical At Home",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )
            )
          ],
        ),
      ),
    );
  }
}

