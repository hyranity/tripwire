import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:tripwire/Util/Quick.dart';

import 'Model/Group.dart';
import 'Model/LogEvent.dart';
import 'Model/MyTheme.dart';

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
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MyTheme.backButton(context),
                      SizedBox(
                        //Provide responsive design
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      groupInfo(),
                      SizedBox(
                        //Provide responsive design
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, right: 18),
                        child: Text(
                          "LOG",
                          style: MyTheme.sectionHeader(context),
                        ),
                      ),
                      logEventList(),
                      SizedBox(
                        //Provide responsive design
                        height: 10,
                      ),
                      actions(),
                    ],
                  ),
                ))));
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
                    height: MediaQuery.of(context).size.height * 0.02,
                  );
                }),
          );
        },
      ),
    );
  }

  Widget locationLog(LogEvent event) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            event.getIcon(40),
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
                      color: event.getColorScheme(false, 45),
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
                          color: event.getColorScheme(false, 10),
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
                        color: event.getColorScheme(true, 4),
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
      height: 140,
      decoration: BoxDecoration(
          color: event.getColorScheme(true, 20),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            event.getIcon(40),
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
                      color: event.getColorScheme(false, 45),
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
                          color: event.getColorScheme(false, 20),
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
                        color: event.getColorScheme(false, 5),
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
      height: 140,
      decoration: BoxDecoration(
          color: event.getColorScheme(true, 20),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding:
        const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            event.getIcon(40),
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
                      color: event.getColorScheme(false, 45),
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
                          color: event.getColorScheme(false, 15),
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
                        color: event.getColorScheme(false, 5),
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

  Widget actions(){
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
            SizedBox(
              width: 5
            ),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize:
                13 + MediaQuery.of(context).size.width * 0.014,
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
            ),SizedBox(
                width: 5
            ),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize:
                13 + MediaQuery.of(context).size.width * 0.014,
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
      height: 120,
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
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 25, bottom: 25),
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
                    color:
                        group.isActive ? Color(0xff9DC398) : Color(0xffC3D6C2),
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
