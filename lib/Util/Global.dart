import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class Global {
  static Pedometer pedometer; // Pedometer

  // Stores the latest step data that you can listen() to
  static Stream<PedestrianStatus> pedestrianStatusStream;
  static Stream<StepCount> stepCountStream;

  // Stores the latest step data but you need to repeatedly access it
  static int stepCount = 0;

  static Future<void> beginListening() async {
    // Initialize pedometer
    pedometer = Pedometer();

    // Begin listening
    pedestrianStatusStream = await Pedometer.pedestrianStatusStream;
    stepCountStream = await Pedometer.stepCountStream;

    // To store steps in stepCount variable
    stepCountStream.listen((event) {
      stepCount = event.steps;
    });
  }
}
