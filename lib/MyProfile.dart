import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:tripwire/Util/Global.dart';
import 'package:tripwire/Util/Quick.dart';
import 'package:tripwire/login.dart';

import 'Model/MyTheme.dart';

class MyProfile extends StatefulWidget {
  MyProfile({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyProfile createState() => _MyProfile();
}

class _MyProfile extends State<MyProfile> {
  int steps = Global.stepCount; // Global.stepCount stores the last known step value
  String status = "stopped";

  @override
  void initState() {
    super.initState();
    listenToChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * .45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.indigo],
                ),
              ),
              child: Center(
                child: Column (
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage("https://cache.desktopnexus.com/thumbseg/1847/1847388-bigthumbnail.jpg"),
                      radius: 50.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Sinon",
                      style: GoogleFonts.poppins(
                        fontSize: 25.0,
                        color:Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * .55,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Padding (
                padding: const EdgeInsets.symmetric(vertical: 30.0,horizontal: 16.0),
                child: Column (

                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Name",
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color:Colors.indigo,
                      ),
                    ),Text(
                      "Sinon",
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        decoration: TextDecoration.none,
                        color:Colors.blue,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Email",
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color:Colors.indigo,
                      ),
                    ),
                    Text(
                      "sinon@sao.com",
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        decoration: TextDecoration.none,
                        color:Colors.blue,
                      ),
                    ),
                    SizedBox(
                      height: Quick.getDeviceSize(context).height * 0.05,
                    ),
                    Container (
                      alignment: Alignment.bottomCenter,
                        child: RaisedButton(
                          onPressed: () {
                            Logout();
                          },
                          shape: RoundedRectangleBorder (
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [Colors.red,Colors.redAccent]
                              ),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: Quick.getDeviceSize(context).width, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text("Log out",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 26.0, fontWeight:FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                    ),
                  ],
                ),
              )
            )
          ],
        ),
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .35,
              right: 20.0,
              left: 20.0),
          child: Container(
            height: 120.0,
            width: MediaQuery.of(context).size.width,
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 22.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column (
                        children: <Widget>[
                          Text(
                            "Group Joined",
                            style: GoogleFonts.poppins(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color:Colors.blue,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            "1",
                            style: GoogleFonts.poppins(
                              fontSize: 15.0,
                              color:Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column (
                        children: <Widget>[
                          Text(
                            "Steps Taken",
                            style: GoogleFonts.poppins(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color:Colors.blue,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            "123",
                            style: GoogleFonts.poppins(
                              fontSize: 15.0,
                              color:Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) //Card
      ],
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
