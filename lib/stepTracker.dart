import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:tripwire/Util/Global.dart';
import 'package:tripwire/Util/Quick.dart';

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
      body: Center(
        child: Container(
          color: color,
          width: Quick.getDeviceSize(context).width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  steps.toString() + " steps taken",
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
}
