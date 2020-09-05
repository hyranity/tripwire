import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinycolor/tinycolor.dart';

import 'Model/LogEvent.dart';
import 'Model/MyTheme.dart';
import 'Model/world_time.dart';

class PollPage extends StatefulWidget {
  PollPage({Key key, @required this.id}) : super(key: key);
  final String id;

  @override
  _PollPage createState() => _PollPage();
}

class _PollPage extends State<PollPage> {
  final questionController = new TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
   //Main UI
    return Scaffold(
      body: new GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Container(
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
                    padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Poll",
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontSize: 35,
                              color: TinyColor.fromString("#de6676").darken(35).color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ), //Title
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Ask a quick question from everyone",
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: TinyColor.fromString("#de6676").darken(35).color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ), //Description
                        SizedBox(
                          //Provide responsive design
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        TextField(
                          controller: questionController,
                          autocorrect: true,
                          maxLines: 3,
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: "Question",
                            labelStyle: TextStyle(
                              color:  TinyColor.fromString("#de6676").darken(45).color,
                              fontSize: 20,
                            ),
                          ),
                          style: TextStyle(
                            height:2.0,
                            color:Colors.black,
                          ),
                        ),
                        SizedBox(
                          //Provide responsive design
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),

                        //Post button
                        InkWell(
                          onTap: () {
                            PollEvent(questionController.text);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: LogEvent.getColorScheme("poll", true, 20),
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
                                    color: TinyColor.fromString("#de6676").darken(35).color,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "Post",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13 + MediaQuery.of(context).size.width * 0.014,
                                      color: TinyColor.fromString("#de6676").darken(35).color,
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                    ),
                                  )
                                ],
                              ),
                            ),
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
      ),
    );
  }

  Future<FirebaseUser> PollEvent(String question) async {
    var date = DateTime.now();
    var eventDb = FirebaseDatabase.instance.reference().child("groups").child(widget.id).child("events").child(date.day.toString() + "-" + date.month.toString() + "-" + date.year.toString());
    final FirebaseUser user = await auth.currentUser();


    await eventDb.push().set({
      'title' : 'Poll Question',
      'sender' : user.uid,
      'receiver' : 'all',
      'triggerPerson' : user.displayName.trim(),
      'groupId' : widget.id,
      'type' : 'poll',
      'sentTime': DateTime.now().toString(),
      'question' : question,
      'yes' :0,
      'no' :0,
    });

    MyTheme.alertMsg(context, "Polled ", "Your question is sent to everyone in this group.");
  }

}