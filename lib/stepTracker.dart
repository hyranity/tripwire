import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:tripwire/Util/Global.dart';
import 'package:tripwire/Util/Quick.dart';

import 'Model/MyTheme.dart';
import 'login.dart';

class StepTracker extends StatefulWidget {
  StepTracker({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StepTracker createState() => _StepTracker();
}

class _StepTracker extends State<StepTracker> {
  int steps = Global.stepCount; // Global.stepCount stores the last known step value
  String status = "stopped";

  @override
  void initState() {
    super.initState();
    listenToChanges();
  }

  @override
  Widget build(BuildContext context) {

    // To show Green color when walking
    var color = Colors.white;
    if (status == "walking") color = Colors.green;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                color: Colors.white,
                padding: EdgeInsets.only(top: 10, left: 18),
                width: Quick.getDeviceSize(context).width,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Steps",

                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: MyTheme.accentColor,

                        ),
                      ),
                      Text(
                        steps.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 70,
                          fontWeight: FontWeight.w500,
                          color: MyTheme.accentColor,
                          height: 1,
                        ),
                      ),
                      Container(
                        child: Text(
                          status,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MyTheme.backButton(context),
                ),
              ),
              Positioned (
                right: 5,
                child : InkWell (
                  child: InkWell(
                    onTap: () {
                      Logout();
                    },
                    child: Container (
                      height:60,
                      width:60,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 25,
                              color: Colors.grey.withOpacity(0.3),
                            )
                          ]),
                      child: Icon(
                        Icons.exit_to_app,
                        size: 25,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Listen to steps
  void listenToChanges() {

    // Upon a change in steps
    Global.stepCountStream.listen((event) {

      // Rebuild the entire screen
      setState(() {
        steps = event.steps;
      });

    });

    // Upon a change in walking status
    Global.pedestrianStatusStream.listen((event) {

      // Rebuild the entire screen
      setState(() {
        status = event.status;
      });

    });
  }

  Future<void> Logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    }
    catch(ex) {
      print("Error : $ex");
    }

    Quick.navigate(context, () => Login());
  }
}
