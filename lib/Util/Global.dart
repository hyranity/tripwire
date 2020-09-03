import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';
import 'package:tripwire/Model/MyTheme.dart';

import 'DB.dart';

class Global {
  // Stores the latest step data that you can listen() to
  static Stream<PedestrianStatus> pedestrianStatusStream;
  static Stream<StepCount> stepCountStream;

  // Stores the latest step data but you need to repeatedly access it
  static int stepCount = 0;

  static Future<void> beginListening(context) async {
    // Begin listening


      pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      stepCountStream = Pedometer.stepCountStream;


      // To store steps in stepCount variable
      stepCountStream.listen((event) {
        stepCount = event.steps;

      }).onError((onError) {
        MyTheme.alertMsg(context, "Couldn't count steps",
            "It seems like your device does not support this step counter feature.");
      });

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
}
