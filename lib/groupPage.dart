import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:tripwire/GroupProfile.dart';
import 'package:tripwire/Model/CurrentLocation.dart';
import 'package:tripwire/Model/world_time.dart';
import 'package:tripwire/Util/Global.dart';
import 'package:tripwire/Util/Quick.dart';
import 'package:tripwire/ping.dart';

import 'Model/Group.dart';
import 'Model/LogEvent.dart';
import 'Model/MyTheme.dart';
import 'Model/action.dart';
import 'Util/DB.dart';
import 'come.dart';
import 'poll.dart';
import 'rally.dart';

class GroupPage extends StatefulWidget {
  GroupPage({Key key, this.title, this.id, @required this.group})
      : super(key: key);

  final String title;
  final String id;

  Group group;

  @override
  _GroupPage createState() => _GroupPage();
}

class _GroupPage extends State<GroupPage> {
  int retryConnect = 0;
  Group group;
  Placemark location;
  TextEditingController locationText = new TextEditingController();
  String logResult = "Successful log";
  var id = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  final replyController = new TextEditingController();
  bool logButtonEnabled = true;

  @override
  Widget build(BuildContext context) {
    //Attempt to get group data
    if (group == null && retryConnect < 5) {
      retryConnect++;
      print("Getting group data.... try #" + retryConnect.toString());
      loadGroupData();
      loadLocation();
      calculateStepCount();
    }

    //Build main UI
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Container(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            alignment: Alignment.centerLeft,
                            child: MyTheme.backButton(context)),
                        SizedBox(
                          //Provide responsive design
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        InkWell(
                          onTap: () {
                            Quick.navigate(
                                context, () => GroupProfile(group: group));
                          },
                          child: Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: groupInfo()),
                        ),
                        SizedBox(
                          //Provide responsive design
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0, right: 18),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              "TODAY'S LOG",
                              style: MyTheme.sectionHeader(context),
                            ),
                          ),
                        ),
                        logEventList(),
                        SizedBox(
                          //Provide responsive design
                          height: 10,
                        ),
                        InkWell(
                          child: actions(),
                          onTap: () {
                            action(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ))));
  }

  calculateStepCount() {
    // Because step count persist BEFORE joining the group, make the current step zero by subtracting with stepsWhenJoining

    // Is this group active?
    FirebaseDatabase.instance
        .reference()
        .child("groups")
        .child(group.id)
        .once()
        .then((DataSnapshot groupSnap) {
      Map<dynamic, dynamic> groupObj = groupSnap.value;
      var groupStatus =
          groupObj["status"] == null ? "inactive" : groupObj["status"];

      if (groupStatus == "inactive") {
        // End here since it's not active
        return;
      }

      // Access member WITHIN group tree
      FirebaseAuth.instance.currentUser().then((user) {
        var groupMember = FirebaseDatabase.instance
            .reference()
            .child("groups")
            .child(group.id)
            .child("members")
            .child(user.uid);

        groupMember.once().then((DataSnapshot userSnap) {
          Map<dynamic, dynamic> member = userSnap.value;
          int stepCountWhenJoined = userSnap.value["stepCountWhenJoined"];
          int currentStepCount = userSnap.value["stepCount"] == null
              ? 0
              : userSnap.value["stepCount"];

          // If -1, that means this user is the creator. Set this step = currentStep
          if (userSnap.value["stepCountWhenJoined"] == -1) {
            stepCountWhenJoined = Global.stepCount;
            // Update step count
            currentStepCount = 0;
          }
          // If current step count is lower, means user JUST restarted phone; add on to the DB one
          else if (userSnap.value["stepCountWhenJoined"] > Global.stepCount) {
            stepCountWhenJoined = 0;
            currentStepCount = Global.stepCount;

            print("user just restarted phone");
          } else {
            // Update step count
            currentStepCount = Global.stepCount -
                stepCountWhenJoined; // Because user may join at step 100, few mins later at step 300, means 200 REAL steps
          }

          // Update member
          groupMember.update({
            "stepCountWhenJoined": stepCountWhenJoined,
            "stepCount": currentStepCount,
          });
        });
      });
    });
  }

  // To load location
  loadLocation() {
    Quick.getLocation().then((location) {
      setState(() {
        this.location = location;
        locationText.text =
            (location.subLocality == "" ? "N/A" : location.subLocality) +
                ", " +
                location.locality;
        print(locationText.text);
      });
    });
  }

  // Show log location window
  logLocation(context) {
    loadLocation();
    showDialog(
        context: context,
        builder: (BuildContext innerContext) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 18.0, bottom: 18),
                child: Wrap(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: MediaQuery.of(context).viewInsets,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Log location",
                            style: GoogleFonts.poppins(
                              fontSize: 35,
                              fontWeight: FontWeight.w600,
                              color: MyTheme.accentColor,
                            ),
                          ),
                        ),
                        Text(
                          "Log your location into the group journal, accessible on the website.",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: MyTheme.accentColor.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Your location:",
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: MyTheme.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: MyTheme.primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: TextField(
                              controller: locationText,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                  hintText: "Your current location",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: MyTheme.accentColor.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent))),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: MyTheme.accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: (text) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // LET'S GO BUTTON
                        Row(
                          children: [
                            new Expanded(child: logButton()),
                            SizedBox(
                              width: 15,
                            ),
                            new Expanded(child: cancelLogButton()),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

// LET'S GO BUTTON
  Widget logButton() {
    return InkWell(
      onTap: () {
        if (logButtonEnabled) {
          print("Locking button");
          setState(() {
            logButtonEnabled = false; // Prevent button spamming
          });
          performLogLocation(context);
        } else {}
      },
      child: Container(

        width: Quick.getDeviceSize(context).width,
        decoration: BoxDecoration(
          color: MyTheme.accentColor,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Log",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CANCEL LOG BUTTON
  Widget cancelLogButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        width: Quick.getDeviceSize(context).width,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cancel,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Cancel",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Log the user's location
  performLogLocation(context) {
    Quick.getWeather(location).then((weather) {
      int coolDownMins =
          30; // Minutes until the next event is count as a separate one, even if same location

      if (locationText.text.length == 0) {
        logError(context, "Location cannot be empty!");
        setState(() {
          logButtonEnabled = true; // Prevent button spamming
        });
        return;
      }

      // Find today's date in journal
      var date = DateTime.now();
      var events = FirebaseDatabase.instance
          .reference()
          .child("groups")
          .child(group.id)
          .child("events")
          .child(date.day.toString() +
              "-" +
              date.month.toString() +
              "-" +
              date.year.toString());

      events.once().then((DataSnapshot snapshot) {
        var eventLocationExists = false; // If a location already logged today

        Map<dynamic, dynamic> eventList = snapshot.value;

        // Check if an event day already created
        if (eventList != null) {
          // Loop through each event
          for (var event in eventList.values) {
            if (event["type"] == "location") {
              // Check how long since the event was made
              var difference = DateTime.now()
                  .difference(DateTime.parse(event["sentTime"]))
                  .inMinutes;

              // Is this location already logged within the cooldown limit?
              if (locationText.text == event["location"] &&
                  difference < coolDownMins &&
                  difference >= 0) {
                // Event exists
                eventLocationExists = true;

                //Is current user already logged inside?
                Map<dynamic, dynamic> attendees = event["attendees"];
                print(attendees);
                FirebaseAuth.instance.currentUser().then((user) {
                  if (attendees != null && attendees[user.uid] != null) {
                    // User already logged this location
                    print("User already attended");
                    logSuccess(context, "Location already logged!");
                    setState(() {
                      logButtonEnabled = true; // Prevent button spamming
                    });
                  } else {
                    // Not yet, add this member inside
                    var thisLoggedLocation = FirebaseDatabase.instance
                        .reference()
                        .child("groups")
                        .child(group.id)
                        .child("events")
                        .child(date.day.toString() +
                            "-" +
                            date.month.toString() +
                            "-" +
                            date.year.toString())
                        .child(event["id"]);

                    // New attendant
                    print(thisLoggedLocation.path);
                    thisLoggedLocation
                        .child("attendees")
                        .update({user.uid: user.displayName}).then((value) {
                      setState(() {
                        logButtonEnabled = true; // Prevent button spamming
                      });

                      logSuccess(context, "You participated in this logging!");
                    });
                  }
                });

                break; // Break if event location already exist
              }
            }
          }
        }

        // Not logged yet
        if (!eventLocationExists) {
          logSuccess(context, "Location logged successfully!");

          // Create new log event and add the user inside it
          FirebaseAuth.instance.currentUser().then((user) {
            var logEvent = FirebaseDatabase.instance
                .reference()
                .child("groups")
                .child(group.id)
                .child("events")
                .child(date.day.toString() +
                "-" +
                date.month.toString() +
                "-" +
                date.year.toString());

            var id = logEvent
                .push()
                .key;

            logEvent.child(id).set({
              "type": "location",
              "location": locationText.text,
              "temperature":
              weather.temperature.celsius.toStringAsFixed(0) + "°C",
              "weather": weather.weatherMain,
              "sentTime": DateTime.now().toString(),
              "id": id,
              "attendees": {
                user.uid: user.displayName,
              }
            }).then((value) {
              setState(() {
                logButtonEnabled = true; // Prevent button spamming
              });
            });
          });
        }
      });
    });
  }

  action(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            height: Quick.getDeviceSize(context).height * 0.65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.grey.withOpacity(1),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 18.0, left: 35),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Actions",
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
                actionList(),
                SizedBox(
                  height: Quick.getDeviceSize(context).height * 0.025,
                ),
                InkWell(
                  onTap: () {
                    logLocation(context);
                  },
                  child: Container(
                    alignment: Alignment.center,

                    width: 300,
                    decoration: BoxDecoration(
                      color: MyTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          offset: Offset(0, 10),
                          color: Colors.grey.withOpacity(1),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Log location",
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              color: MyTheme.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            location != null
                                ? (location.subLocality == ""
                                ? "N/A"
                                : location.subLocality) +
                                ", " +
                                location.locality
                                : "No location found", // Load current location
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              height: 1,
                              fontSize: 23,
                              color: MyTheme.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          );
        });
  }

  Future<List<ActionButton>> getActionArray() async {
    List<ActionButton> buttons = new List();

    buttons.add(new ActionButton(
      name: "Rally",
      description: "Ask everyone to gather at your location.",
      type: "rally",
      dialogTitle: "Rally?",
      dialogDesc: "Rally everyone?",
    ));
    buttons.add(new ActionButton(
      name: "Poll",
      description: "Ask everyone a 'yes' and 'no' question.",
      type: "poll",
    ));
    buttons.add(new ActionButton(
      name: "Come",
      description: "Call a single friend over to your location.",
      type: "summon",
    ));
    buttons.add(new ActionButton(
      name: "Ping",
      description: "Request your friend's location",
      type: "ping",
    ));
    return buttons;
  }

  Widget actionList() {
    return Container(
      height: 250,
      child: FutureBuilder(
        future: getActionArray(),
        builder: (BuildContext context,
            AsyncSnapshot<List<ActionButton>> buttonList) {
          // If no data
          if (buttonList.connectionState != ConnectionState.done ||
              !buttonList.hasData) {
            return new CircularProgressIndicator();
          }

          //Else
          return ListView.separated(
              padding: EdgeInsets.only(left: 28, right: 28),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                //Individual button
                return actionButtonItem(buttonList.data[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(width: 30);
              },
              itemCount: buttonList.data.length);
        },
      ),
    );
  }

  // Show unable to log location error
  Widget logError(context, message) {
    showDialog(
        context: context,
        builder: (BuildContext innerContext) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 18.0, bottom: 18),
                child: Wrap(
                  children: [
                    Column(
                      children: [
                        Text(
                          message,
                          maxLines: 4,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: MyTheme.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 100,
                            decoration: BoxDecoration(
                              color: MyTheme.accentColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Ok",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // Show log success
  Widget logSuccess(context, String message) {
    // Close other dialog
    Navigator.of(context).pop();

    showDialog(
        context: context,
        builder: (BuildContext innerContext) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 18.0, bottom: 18),
                child: Wrap(
                  children: [
                    Column(
                      children: [
                        Text(
                          message,
                          maxLines: 4,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: MyTheme.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 100,
                            decoration: BoxDecoration(
                              color: MyTheme.accentColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Ok",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //Dialog Box Widget
  Widget confirmationDialog(context, String title, String desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            height: 300,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 0.0, 15.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 0.0, 60.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      desc,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxHeight: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            RallyEvent();
                          },
                          child: confirmOption(Icons.check, "do it")),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(onTap: () {
                        Navigator.pop(context);
                      }, child: cancelOption(Icons.cancel, "nah")),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget actionButtonItem(ActionButton button) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 25),
      child: InkWell(
        onTap: () {
          print("press");
          if (button.type == "rally")
            confirmationDialog(context, button.dialogTitle, button.dialogDesc);
          else if (button.type == "poll")
            Quick.navigate(context, () => PollPage(id: group.id));
          else if (button.type == "ping")
            Quick.navigate(context, () => PingPage(id: group.id));
          else if (button.type == "summon")
            Quick.navigate(context, () => ComePage(id: group.id));
        },
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: LogEvent.getColorScheme(button.type, true, 20),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                offset: Offset(0, 10),
                color: Colors.grey.withOpacity(1),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15, top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      button.name,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 35,
                        color: LogEvent.getColorScheme(button.type, false, 45),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    new Spacer(),
                    LogEvent.getIcon(button.type, 50),
                  ],
                ),
                Text(
                  button.description,
                  maxLines: 3,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    color: LogEvent.getColorScheme(button.type, false, 45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Get group data
  void loadGroupData() {
    setState(() {
      group = widget.group;
      updateGroupData();
    });
  }

  void updateGroupData() async {
    var groupDb = FirebaseDatabase.instance
        .reference()
        .child("groups")
        .child(group.id)
        .child("members");
    int countUser = 0;

    await groupDb.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> groups = snapshot.value;

      groups.forEach((key, value) async {
        countUser += 1;
      });
      group.members = groups["members"];
      group.memberCount = countUser;
    });
  }

  Future<List<LogEvent>> getEvents() async {
    //Getting today's events from firebase
    var date = DateTime.now();
    var eventDb = FirebaseDatabase.instance
        .reference()
        .child("groups")
        .child(group.id)
        .child("events")
        .child(date.day.toString() +
        "-" +
        date.month.toString() +
        "-" +
        date.year.toString()).orderByChild("sentTime");

    final FirebaseUser user = await auth.currentUser();

    id = user.uid;

    return eventDb.once().then((DataSnapshot snapshot) {
      List<LogEvent> eventList = new List();

      // Loop through each day
      try {
        snapshot.value.forEach((key, value) {
          print(key);
          Map<dynamic, dynamic> events = value;

          if (events["type"] == "location") {
            String attendStr = "";

            //Trigger person is taken from attendees
            if (events["attendees"] != null) {
              // Add initial name
              attendStr = events["attendees"].values.toList()[0];

              // Add "and others"
              if (events["attendees"].length > 1) {
                attendStr = events["attendees"].length.toString() + " pax";
              }
            }


            eventList.add(new LogEvent(
              title: events["location"],
              triggerPerson: attendStr,
              type: events['type'],
              sentTime: DateTime.parse(events['sentTime']),
              isCommunication: false,
              attendees: events['attendees'],
            ));
          }


          if (((events['receiver'] == user.uid ||
              events['receiver'] == 'all') &&
              events['groupId'] == group.id)) {
            if (events['type'] == "ping") {
              eventList.add(new LogEvent(
                title: events['title'],
                triggerPerson: events['triggerPerson'],
                type: events['type'],
                pingLocation: events['pingLocation'],
                isReplied: events['isReplied'],
                sentTime: DateTime.parse(events['sentTime']),
                isCommunication: true,
                sender: events['sender'],
                receiver: events['receiver'],
                location: events['location'],
                answer: events['answer'],
              ));
            } else if (events['type'] == "poll") {
              // If already responded, check whether: events["respondent"][user.uid] != null

              eventList.add(new LogEvent(
                title: events['title'],
                triggerPerson: events['triggerPerson'],
                type: events['type'],
                sentTime: DateTime.parse(events['sentTime']),
                isCommunication: true,
                sender: events['sender'],
                receiver: events['receiver'],
                question: events['question'],
                yes: events['yes'],
                no: events['no'],
                response: events["respondent"] != null
                    ? events["respondent"][user.uid] !=
                    null // User has responded?
                    ? events["respondent"][user.uid]["reply"] // Yes
                    : null
                    : null, // No
              ));
            } else if (events['type'] == "come") {
              eventList.add(new LogEvent(
                title: events['title'],
                triggerPerson: events['triggerPerson'],
                type: events['type'],
                isReplied: events['isReplied'],
                sentTime: DateTime.parse(events['sentTime']),
                isCommunication: true,
                sender: events['sender'],
                receiver: events['receiver'],
                answer: events['answer'],
              ));
            } else if (events["type"] == "rally") {
              eventList.add(new LogEvent(
                title: events['title'],
                triggerPerson: events['triggerPerson'],
                type: events['type'],
                sentTime: DateTime.parse(events['sentTime']),
                isCommunication: true,
                location: events['location'],
                sender: events['sender'],
                receiver: events['receiver'],
              ));
            } else {
              eventList.add(new LogEvent(
                title: events['title'],
                triggerPerson: events['triggerPerson'],
                type: events['type'],
                sentTime: DateTime.parse(events['sentTime']),
                isCommunication: true,
                location: events['location'],
                sender: events['sender'],
                receiver: events['receiver'],
              ));
            }
          } else {
            // Don't show anything
          }
        });
      } on NoSuchMethodError catch (e) {
        print(e.stackTrace);
      }

      return new List.from(eventList.reversed);
    });
  }

  Widget logEventList() {
    FirebaseDatabase.instance
        .reference()
        .child("groups")
        .child(group.id)
        .onChildChanged
        .listen((event) {
      setState(() {});
    });
    return Container(
      alignment: Alignment.topCenter,
      height: Quick.getDeviceSize(context).height * 0.5,
      child: FutureBuilder<List<LogEvent>>(
        future: getEvents(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //If cant obtain event list
          if (snapshot.connectionState != ConnectionState.done)
            return new CircularProgressIndicator();

          if (!snapshot.hasData) {
            return new Container(
              child: Text(
                "No events found",
              ),
            );
          }

          //Has data
          return MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView.separated(
                padding: EdgeInsets.only(top: 18, bottom: 18),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  LogEvent event = snapshot.data[index];

                  if (!event.isCommunication) {
                    //This is a location logging event
                    return locationLog(event);
                  } else {
                    //This is a communication event, so the following designs will be used:
                    //Rally

                    if (event.type == "rally") return rally(event);
                    if (event.type == "ping" && event.isReplied == "no")
                      return ping(event);
                    if (event.type == "ping" && event.isReplied == "yes")
                      return pingBack(event);
                    if (event.type == "come" && event.isReplied == "no")
                      return come(event);
                    if (event.type == "come" && event.isReplied == "yes")
                      return comeBack(event);
                    if (event.type == "poll" && event.sender == id)
                      return pollBack(event);
                    if (event.type == "poll" && event.sender != id)
                      return poll(event);

                    //Default return (if no communication design is available)
                    return locationLog(event);
                  }
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 20,
                  );
                }),
          );
        },
      ),
    );
  }

  Widget locationLog(LogEvent event) {
    return InkWell(
      onTap: () {
        print(event.location);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding:
                      const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Location",
                              style: MyTheme.sectionHeader(context),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: MyTheme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.grey.withOpacity(0.1),
                                  )
                                ]),
                            child: Text(
                              event.title,
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 25,
                                color: MyTheme.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text("Attendees",
                                textAlign: TextAlign.left,
                                style: MyTheme.sectionHeader(context)),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              minHeight:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.3,
                              maxHeight:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.6,
                            ),
                            child: ListView.separated(
                                itemBuilder: (BuildContext context, index) {
                                  return Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: MyTheme.primaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10,
                                            color: Colors.grey.withOpacity(0.1),
                                          )
                                        ]),
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.6,
                                    child: Row(
                                      children: [
                                        Quick.getUserPic(event
                                            .attendees.keys
                                            .elementAt(index), 20),
                                        SizedBox(
                                            width: 10
                                        ),
                                        Text(
                                          event.attendees[event.attendees.keys
                                              .elementAt(index)],
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            color: MyTheme.accentColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, index) {
                                  return new Container(
                                    height: 10,
                                  );
                                },
                                itemCount: event.attendees.length),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              constraints: BoxConstraints(maxHeight: 100),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xffB5E8AF),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10,
                                            color: Colors.grey.withOpacity(0.1),
                                          )
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.check,
                                            color: Color(0xff537050),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "Okay",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13 +
                                                  MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width *
                                                      0.014,
                                              color: Color(0xff537050),
                                              fontWeight: FontWeight.w600,
                                              height: 1,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        height: 90,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                offset: Offset(0, 7),
                color: Colors.grey.withOpacity(0.6),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 25.0, right: 25.0, top: 15, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              LogEvent.getIcon(event.type, 40),
              SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.5,
                    child: Text(
                      event.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 23,
                        color: LogEvent.getColorScheme(event.type, false, 45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery
                              .of(context)
                              .size
                              .width * 0.32,
                        ),
                        child: Text(
                          event.triggerPerson,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize:
                            13 + MediaQuery
                                .of(context)
                                .size
                                .width * 0.014,
                            color:
                            LogEvent.getColorScheme(event.type, false, 10),
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        event.timeSinceSet(),
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize:
                          13 + MediaQuery
                              .of(context)
                              .size
                              .width * 0.014,
                          color: LogEvent.getColorScheme(event.type, true, 4),
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget rally(LogEvent event) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      height: 140,
      decoration: BoxDecoration(
          color: LogEvent.getColorScheme(event.type, true, 20),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              offset: Offset(0, 7),
              color: Colors.grey.withOpacity(0.6),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            LogEvent.getIcon(event.type, 40),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    event.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: LogEvent.getColorScheme(event.type, false, 45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.32,
                      ),
                      child: Text(
                        event.triggerPerson,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize:
                              13 + MediaQuery.of(context).size.width * 0.014,
                          color: LogEvent.getColorScheme(event.type, false, 20),
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      event.timeSinceSet(),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize:
                            13 + MediaQuery.of(context).size.width * 0.014,
                        color: LogEvent.getColorScheme(event.type, false, 5),
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  constraints: BoxConstraints(maxHeight: 100),
                  child: Row(
                    children: <Widget>[
                      Text(
                        event.location,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize:
                          13 + MediaQuery
                              .of(context)
                              .size
                              .width * 0.014,
                          color: LogEvent.getColorScheme(event.type, false, 45),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget ping(LogEvent event) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      height: 150,
      decoration: BoxDecoration(
          color: LogEvent.getColorScheme(event.type, true, 20),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              offset: Offset(0, 7),
              color: Colors.grey.withOpacity(0.6),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            LogEvent.getIcon(event.type, 40),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    event.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: LogEvent.getColorScheme(event.type, false, 45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.32,
                      ),
                      child: Text(
                        event.triggerPerson,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize:
                              13 + MediaQuery.of(context).size.width * 0.014,
                          color: LogEvent.getColorScheme(event.type, false, 15),
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      event.timeSinceSet(),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize:
                            13 + MediaQuery.of(context).size.width * 0.014,
                        color: LogEvent.getColorScheme(event.type, false, 5),
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        child: okOption(event, Icons.my_location, "give"),
                        onTap: () {
                          PingReply(event.sentTime, 'yes');
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        child: noOption(event, Icons.cancel, "nah"),
                        onTap: () {
                          PingReply(event.sentTime, 'no');
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget pingBack(LogEvent event) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      height: 140,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 1.5,
          ),
          color: LogEvent.getColorScheme(event.type, true, 20),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              offset: Offset(0, 7),
              color: Colors.grey.withOpacity(0.6),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            LogEvent.getIcon(event.type, 40),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    event.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: LogEvent.getColorScheme(event.type, false, 45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.32,
                      ),
                      child: Text(
                        event.triggerPerson,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize:
                              13 + MediaQuery.of(context).size.width * 0.014,
                          color: LogEvent.getColorScheme(event.type, false, 15),
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      event.timeSinceSet(),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize:
                            13 + MediaQuery.of(context).size.width * 0.014,
                        color: LogEvent.getColorScheme(event.type, false, 5),
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      if (event.answer == "yes")
                        Text(
                          event.location,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize:
                                13 + MediaQuery.of(context).size.width * 0.014,
                            color:
                                LogEvent.getColorScheme(event.type, false, 45),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Text(
                          "Sorry, not now.",
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize:
                                13 + MediaQuery.of(context).size.width * 0.014,
                            color:
                                LogEvent.getColorScheme(event.type, false, 45),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget poll(LogEvent event) {
    return InkWell(
      onTap: () {
        pollResult(event);
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        height: 150,
        decoration: BoxDecoration(
            color: LogEvent.getColorScheme(event.type, true, 20),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                offset: Offset(0, 7),
                color: Colors.grey.withOpacity(0.6),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 25.0, right: 25.0, top: 15, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              LogEvent.getIcon(event.type, 40),
              SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      event.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 23,
                        color: LogEvent.getColorScheme(event.type, false, 45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.32,
                        ),
                        child: Text(
                          event.triggerPerson,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize:
                                13 + MediaQuery.of(context).size.width * 0.014,
                            color:
                                LogEvent.getColorScheme(event.type, false, 15),
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        event.timeSinceSet(),
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize:
                              13 + MediaQuery.of(context).size.width * 0.014,
                          color: LogEvent.getColorScheme(event.type, false, 5),
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  event.response != null // Did user respond?
                      ?
                      //  Yes, Show response
                      Text(
                          "You said: " + event.response,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize:
                                13 + MediaQuery.of(context).size.width * 0.014,
                            color:
                                LogEvent.getColorScheme(event.type, false, 5),
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        )
                      :
                      // No, Request response
                      Container(
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                child:
                                    okOption(event, Icons.my_location, "okay"),
                                onTap: () {
                                  PollReply(event.sentTime, "yes");
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                child: noOption(event, Icons.cancel, "nah"),
                                onTap: () {
                                  PollReply(event.sentTime, "no");
                                },
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pollBack(LogEvent event) {
    return InkWell(
      onTap: () {
        pollResult(event);
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        height: 150,
        decoration: BoxDecoration(
            color: LogEvent.getColorScheme(event.type, true, 20),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                offset: Offset(0, 7),
                color: Colors.grey.withOpacity(0.6),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 25.0, right: 25.0, top: 15, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              LogEvent.getIcon(event.type, 40),
              SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      event.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 23,
                        color: LogEvent.getColorScheme(event.type, false, 45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.32,
                        ),
                        child: Text(
                          event.triggerPerson,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize:
                                13 + MediaQuery.of(context).size.width * 0.014,
                            color:
                                LogEvent.getColorScheme(event.type, false, 15),
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        event.timeSinceSet(),
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize:
                              13 + MediaQuery.of(context).size.width * 0.014,
                          color: LogEvent.getColorScheme(event.type, false, 5),
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text(
                          event.yes.toString() +
                              " saying yes, \n" +
                              event.no.toString() +
                              " saying no",
                          maxLines: 2,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize:
                                13 + MediaQuery.of(context).size.width * 0.014,
                            color:
                                LogEvent.getColorScheme(event.type, false, 45),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pollResult(LogEvent event) {
    showModalBottomSheet(
        barrierColor: Color.fromRGBO(0, 0, 0, 0.01),
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: Quick.getDeviceSize(context).height * 0.5,
            decoration: BoxDecoration(
                color: LogEvent.getColorScheme(event.type, true, 20),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.grey.withOpacity(1),
                  )
                ]),
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                children: <Widget>[
                  Text("Question",
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: LogEvent.getColorScheme(event.type, false, 10),
                      )),
                  Text(event.question,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: LogEvent.getColorScheme(event.type, false, 20),
                      )),
                ],
              ),
            ),
          );
        });
  }

  Widget come(LogEvent event) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      height: 150,
      decoration: BoxDecoration(
          color: LogEvent.getColorScheme(event.type, true, 20),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              offset: Offset(0, 7),
              color: Colors.grey.withOpacity(0.6),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            LogEvent.getIcon(event.type, 40),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    event.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: LogEvent.getColorScheme(event.type, false, 45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.32,
                      ),
                      child: Text(
                        event.triggerPerson,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize:
                              13 + MediaQuery.of(context).size.width * 0.014,
                          color: LogEvent.getColorScheme(event.type, false, 15),
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      event.timeSinceSet(),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize:
                            13 + MediaQuery.of(context).size.width * 0.014,
                        color: LogEvent.getColorScheme(event.type, false, 5),
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        child: okOption(event, Icons.my_location, "coming"),
                        onTap: () {
                          ComeReply(event.sentTime, "yes");
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        child: noOption(event, Icons.cancel, "nah"),
                        onTap: () {
                          ComeReply(event.sentTime, "no");
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget comeBack(LogEvent event) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      height: 150,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 1.5,
          ),
          color: LogEvent.getColorScheme(event.type, true, 20),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              offset: Offset(0, 7),
              color: Colors.grey.withOpacity(0.6),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            LogEvent.getIcon(event.type, 40),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    event.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: LogEvent.getColorScheme(event.type, false, 45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.32,
                      ),
                      child: Text(
                        event.triggerPerson,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize:
                              13 + MediaQuery.of(context).size.width * 0.014,
                          color: LogEvent.getColorScheme(event.type, false, 15),
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      event.timeSinceSet(),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize:
                            13 + MediaQuery.of(context).size.width * 0.014,
                        color: LogEvent.getColorScheme(event.type, false, 5),
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      if (event.answer == "yes")
                        Text(
                          "I'm coming",
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize:
                                13 + MediaQuery.of(context).size.width * 0.014,
                            color:
                                LogEvent.getColorScheme(event.type, false, 45),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Text(
                          "Sorry, I'm not coming",
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize:
                                13 + MediaQuery.of(context).size.width * 0.014,
                            color:
                                LogEvent.getColorScheme(event.type, false, 45),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget actions() {
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: Quick.getDeviceSize(context).width * 0.5,
        decoration: BoxDecoration(
            color: Color(0xffD5F5D1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                blurRadius: 25,
                color: Colors.grey.withOpacity(0.3),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "ACTIONS",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Color(0xff669260),
            ),
          ),
        ),
      ),
    );
  }

  Widget okOption(LogEvent event, IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xffB5E8AF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Color(0xff537050),
            ),
            SizedBox(width: 5),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13 + MediaQuery.of(context).size.width * 0.014,
                color: Color(0xff537050),
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget noOption(LogEvent event, IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xffECA0A0),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Color(0xff6A4A4A),
            ),
            SizedBox(width: 5),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13 + MediaQuery.of(context).size.width * 0.014,
                color: Color(0xff6A4A4A),
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget confirmOption(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xffB5E8AF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Color(0xff537050),
            ),
            SizedBox(width: 5),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13 + MediaQuery.of(context).size.width * 0.014,
                color: Color(0xff537050),
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget cancelOption(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xffECA0A0),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Color(0xff6A4A4A),
            ),
            SizedBox(width: 5),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13 + MediaQuery.of(context).size.width * 0.014,
                color: Color(0xff6A4A4A),
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget groupInfo() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          color: MyTheme.primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 20, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 7,
                      color: Colors.black.withOpacity(0.3),
                    )
                  ],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(group.photoURL),
                  )),
            ),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    group.name,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: Color(0xff669260),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  group.memberCount.toString() + " people",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Color(0xff9DC398),
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<FirebaseUser> RallyEvent() async {
    var date = DateTime.now();
    var eventDb = FirebaseDatabase.instance
        .reference()
        .child("groups")
        .child(group.id)
        .child("events")
        .child(date.day.toString() +
            "-" +
            date.month.toString() +
            "-" +
            date.year.toString());
    final FirebaseUser user = await auth.currentUser();

    //get time
    WorldTime wt = WorldTime(url: 'Asia/Kuala_Lumpur');
    await wt.getTime();

    Quick.getLocation().then((myLocation) {
      String locationRally =
          (myLocation.subLocality == "" ? "N/A" : myLocation.subLocality) +
              ", " +
              myLocation.locality;

      eventDb.push().set({
        'title': 'Rally Everyone',
        'sender': user.uid,
        'receiver': 'all',
        'triggerPerson': user.displayName.trim(),
        'groupId': group.id,
        'type': 'rally',
        'isReplied': 'no',
        'location': locationRally,
        'sentTime': DateTime.now().toString(),
      });
    });

    MyTheme.alertMsg(
        context, "Rally ", "You have noticed all your group member to rally");
  }

  Future<FirebaseUser> PingReply(DateTime sentTime, String answer) async {
    var date = DateTime.now();
    var eventDb = FirebaseDatabase.instance
        .reference()
        .child("groups")
        .child(group.id)
        .child("events")
        .child(date.day.toString() +
            "-" +
            date.month.toString() +
            "-" +
            date.year.toString());
    final FirebaseUser user = await auth.currentUser();

    WorldTime instance = WorldTime(url: 'Asia/Kuala_Lumpur');
    await instance.getTime();

    Quick.getLocation().then((myLocation) {
      String locationPing =
          (myLocation.subLocality == "" ? "N/A" : myLocation.subLocality) +
              ", " +
              myLocation.locality;

      eventDb.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> events = snapshot.value;
        events.forEach((key, value) {
          if (value['receiver'] == user.uid &&
              value['sentTime'] == sentTime.toString() &&
              value['type'] == 'ping') {
            if (answer == "yes") {
              eventDb.child(key).update({
                'sender': user.uid,
                'receiver': value['sender'],
                'location': locationPing,
                'pingLocation': 'yes',
                'isReplied': 'yes',
                'answer': 'yes',
                'sentTime': DateTime.now().toString(),
              });
            } else if (answer == "no") {
              eventDb.child(key).update({
                'sender': user.uid,
                'receiver': value['sender'],
                'pingLocation': 'yes',
                'isReplied': 'yes',
                'answer': 'no',
                'sentTime': DateTime.now().toString(),
              });
            }
          }
        });
      });
    });
  }

  Future<FirebaseUser> PollReply(DateTime sentTime, String reply) async {
    var date = DateTime.now();
    var eventDb = FirebaseDatabase.instance
        .reference()
        .child("groups")
        .child(group.id)
        .child("events")
        .child(date.day.toString() +
            "-" +
            date.month.toString() +
            "-" +
            date.year.toString());
    final FirebaseUser user = await auth.currentUser();
    bool isAnswered = true;
    int yes = 0;
    int no = 0;

    await eventDb.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> events = snapshot.value;
      events.forEach((key, value) {
        if (value['receiver'] == "all" &&
            !value['respondent'].toString().contains(user.uid) &&
            value['sentTime'] == sentTime.toString() &&
            value['type'] == 'poll') {
          yes = value['yes'];
          no = value['no'];

          if (reply == "yes") {
            yes += 1;
          } else if (reply == "no") {
            no += 1;
          }

          eventDb.child(key).update({
            'isReplied': 'yes',
            'yes': yes,
            'no': no,
          });
          eventDb.child(key).child("respondent").update({
            user.uid: {
              "name": user.displayName,
              "reply": reply,
            },
          });
          isAnswered = false;
        }
      });
    });
  }

  Future<FirebaseUser> ComeReply(DateTime sentTime, String answer) async {
    var date = DateTime.now();
    var eventDb = FirebaseDatabase.instance
        .reference()
        .child("groups")
        .child(group.id)
        .child("events")
        .child(date.day.toString() +
            "-" +
            date.month.toString() +
            "-" +
            date.year.toString());
    final FirebaseUser user = await auth.currentUser();

    WorldTime instance = WorldTime(url: 'Asia/Kuala_Lumpur');
    await instance.getTime();

    eventDb.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> events = snapshot.value;
      events.forEach((key, value) {
        if (value['receiver'] == user.uid &&
            value['sentTime'] == sentTime.toString() &&
            value['type'] == 'come') {
          if (answer == "yes") {
            eventDb.child(key).update({
              'sender': user.uid,
              'receiver': value['sender'],
              'pingLocation': 'yes',
              'isReplied': 'yes',
              'answer': 'yes',
              'sentTime': DateTime.now().toString(),
            });
          } else if (answer == "no") {
            eventDb.child(key).update({
              'sender': user.uid,
              'receiver': value['sender'],
              'pingLocation': 'yes',
              'isReplied': 'yes',
              'answer': 'no',
              'sentTime': DateTime.now().toString(),
            });
          }
        }
      });
    });
    MyTheme.alertMsg(context, "Reply sent", "You have sent your reply");
  }
}
