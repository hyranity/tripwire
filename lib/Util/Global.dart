import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';
import 'package:tripwire/Model/MyTheme.dart';
import 'package:tripwire/Util/Quick.dart';

import 'DB.dart';

class Global {
  // Stores the latest step data that you can listen() to
  static Stream<PedestrianStatus> pedestrianStatusStream;
  static Stream<StepCount> stepCountStream;

  // Stores the latest step data but you need to repeatedly access it
  static int stepCount = 0;

  static Future<void> beginListening(context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();

    pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    stepCountStream = Pedometer.stepCountStream;

    // To store steps in stepCount variable
    try {
      stepCountStream.listen((event) {
        stepCount = event.steps;
        print(stepCount);
        if (stepCount % 10 == 0) {
          Quick.getLocation().then((place) {
            // For every 100 steps
            FirebaseDatabase.instance
                .reference()
                .child("member")
                .child(user.uid)
                .update({
              'lastLocation': place.subLocality +
                  ", " +
                  place.administrativeArea +
                  ", " +
                  place.country,
              'lastLoggedTime': DateTime.now().toString(),
            });
          });
        }
      }).onError((onError) {
        MyTheme.alertMsg(context, "Couldn't track steps",
            "Your device doesn't support the step counter feature.");
      });
    } on PlatformException catch (e) {
      MyTheme.alertMsg(context, "Couldn't track steps",
          "Your device doesn't support the step counter feature.");
    }
  }

  static Future<dynamic> getUserName() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    return DB
        .get(DB.db().reference().child("member").child(user.uid))
        .then((var value) {
      return value["name"];
    });
  }

  static Future<dynamic> getDBUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    return DB
        .get(DB.db().reference().child("member").child(user.uid))
        .then((var value) {
      return value;
    });
  }
}
