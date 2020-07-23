import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:tripwire/Util/Quick.dart';

import 'Model/Group.dart';
import 'Model/LogEvent.dart';
import 'Model/MyTheme.dart';
import 'Model/action.dart';

class GroupPage extends StatefulWidget {
  GroupPage({Key key, this.title, @required this.group}) : super(key: key);

  final String title;
  Group group;

  @override
  _GroupPage createState() => _GroupPage();
}

class _GroupPage extends State<GroupPage> {
  int retryConnect = 0;
  Group group;

  @override
  Widget build(BuildContext context) {
    //Attempt to get group data
    if (group == null && retryConnect < 5) {
      retryConnect++;
      print("Getting group data.... try #" + retryConnect.toString());
      loadGroupData();
    }

    //Build main UI
    return Scaffold(
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
                        Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: groupInfo()),
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
                              "LOG",
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
                Container(
                  alignment: Alignment.center,
                  height: 100,
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
                          "Sabah, Malaysia adasdasd asd sa",
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 23,
                            color: MyTheme.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
        type: "rally"));
    buttons.add(new ActionButton(
        name: "Poll",
        description: "Ask everyone a 'yes' and 'no' question.",
        type: "poll"));
    buttons.add(new ActionButton(
        name: "Come",
        description: "Call a single friend over to your location.",
        type: "summon"));
    buttons.add(new ActionButton(
        name: "Ping",
        description: "Request your friend's location",
        type: "ping"));
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

  Widget actionButtonItem(ActionButton button) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 25),
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
          padding:
              const EdgeInsets.only(left: 15.0, right: 15, top: 10, bottom: 10),
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
    );
  }

  //Get group data
  void loadGroupData() {
    setState(() {
      group = widget.group;
    });
  }

  Future<List<LogEvent>> getEvents() async {
    List<LogEvent> eventList = new List();

    //Dummy data
    eventList.add(new LogEvent(
        title: "KLCC",
        triggerPerson: "Everyone",
        type: "location",
        sentTime: DateTime(2020, 7, 21, 18, 50)));

    eventList.add(new LogEvent(
        title: "Rally @ Hilton Hotel Lobby",
        triggerPerson: "Johann",
        type: "rally",
        isCommunication: true,
        sentTime: DateTime(2020, 7, 21, 12, 50)));

    eventList.add(new LogEvent(
        title: "Requesting location",
        triggerPerson: "Kelvin",
        type: "ping",
        isCommunication: true,
        sentTime: DateTime(2020, 7, 20, 20, 50)));

    return eventList;
  }

  Widget logEventList() {
    return Container(
      alignment: Alignment.center,
      height: Quick.getDeviceSize(context).height * 0.5,
      child: FutureBuilder<List<LogEvent>>(
        future: getEvents(),
        builder:
            (BuildContext context, AsyncSnapshot<List<LogEvent>> snapshot) {
          //If cant obtain event list
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData) return new CircularProgressIndicator();

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
                    if (event.type == "ping") return ping(event);

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
    return Container(
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
                  width: MediaQuery.of(context).size.width * 0.6,
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
                          color: LogEvent.getColorScheme(event.type, false, 10),
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
                  width: MediaQuery.of(context).size.width * 0.6,
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
                      okOption(event, Icons.directions_run, "otw"),
                      SizedBox(
                        width: 10,
                      ),
                      noOption(event, Icons.cancel, "nah"),
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
                  width: MediaQuery.of(context).size.width * 0.6,
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
                      okOption(event, Icons.my_location, "give"),
                      SizedBox(
                        width: 10,
                      ),
                      noOption(event, Icons.cancel, "nah"),
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
                    image: NetworkImage(
                        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                  )),
            ),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
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
}
