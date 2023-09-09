
import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/authentication/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

 class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm(){

    if(!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "Please check the email address!");
    }

    else if(passwordTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Password is mandatory.");
    }
    else{
      loginUserNow();

    }

  }
  loginUserNow() async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext c){
          return ProgressDialog(message: "Logging in ...",);
        }
    );
    final User? firebaseUser = (
        await fAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error: " + msg.toString());
        })
    ).user;

    if(firebaseUser != null)
    {
      DatabaseReference doctorsRef = FirebaseDatabase.instance.ref().child("users");
      doctorsRef.child(firebaseUser.uid).once().then((doctorkey)
          {
          final snap = doctorkey.snapshot;
          if(snap.value != null){
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: "Logged in Successfully.");
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
          }
          else{
          Fluttertoast.showToast(msg: "No record exist with this email");
          fAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
          }
      });
    }
    else
    {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error occured during login.");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(20.0),

          child: Column(
            children: [
              const SizedBox(height: 30,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo.png"),
              ),
              const SizedBox(height: 10,),

              const Text(
                "Login as User",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

              ),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style:const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14),
                ),

              ),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style:const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14                ),
                ),

              ),

              const SizedBox(height: 20,),

              ElevatedButton(onPressed:()
              {
                validateForm();
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              TextButton(
                child:const Text(
                  "Don't have an account? Signup Here"
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder:(c)=>SignUpScreen()));
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
