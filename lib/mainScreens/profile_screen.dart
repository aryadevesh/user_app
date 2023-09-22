import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/widgets/info_design_ui.dart';


class ProfileScreen extends StatefulWidget
{
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}




class _ProfileScreenState extends State<ProfileScreen>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //name
            Text(
              userModelCurrentInfo!.name!,
              style: const TextStyle(
                fontSize: 50.0,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.lightBlue,
                height: 2,
                thickness: 2,
              ),
            ),

            const SizedBox(height: 38.0,),

            //phone
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo!.phone!,
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo!.email!,
              iconData: Icons.email,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
                onPressed: ()
                {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
            )

          ],
        ),
      ),
    );
  }
}
