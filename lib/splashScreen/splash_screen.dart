import 'dart:async';

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
  startTimer(){
    fAuth.currentUser!=null?AssistantMethods.readCurrentOnlineUserInfo(): null;
    Timer(const Duration(seconds: 3), () async
    {
      Navigator.push(context, MaterialPageRoute(builder: (c)=>  MainScreen()));
      if(await fAuth.currentUser != null)
      {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      }
      else
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=>  LoginScreen()));
      }
      // send user to home screen
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

