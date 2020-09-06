import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwire/Util/Global.dart';

import 'Model/MyTheme.dart';
import 'Util/Quick.dart';

class JoinPage extends StatefulWidget {
  @override
  _JoinPage createState() => _JoinPage();
}

class _JoinPage extends State<JoinPage> {
  final codeController = new TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Join Group",
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 35,
                            color: Color(0xff669260),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Ask for the 5-character code, then enter it here to join the group",
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Color(0xff669260),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        //Provide responsive design
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Container(
                        width: Quick.getDeviceSize(context).width * 0.8,
                        decoration: BoxDecoration(
                            color: Color(0xffA3D89F),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                offset: Offset(0, 5),
                                color: Colors.grey.withOpacity(0.3),
                              )
                            ]),
                        child: TextFormField(
                          controller: codeController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            labelText: 'CODE',
                            border: InputBorder.none,
                            focusColor: Colors.red,
                            labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        //Provide responsive design
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Color(0xffD5F5D1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 15,
                                color: Colors.grey.withOpacity(0.3),
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              JoinEvent(codeController.text);
                            },
                            child: Text(
                              "LET'S GO",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff669260),
                              ),
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
    );
  }

  Future<FirebaseUser> JoinEvent(String code) async {
    var groupDb = FirebaseDatabase.instance.reference().child("groups");
    final FirebaseUser user = await auth.currentUser();
    bool codeFound = false;

    await groupDb.once().then((DataSnapshot snapshot) async {
      Map<dynamic, dynamic> groups = snapshot.value;

      groups.forEach((key, value) async {
        if (key == code) {
          codeFound = true;
        }
      });
    });

    if (codeFound == true) {
      var joinGroupDb =
          FirebaseDatabase.instance.reference().child("groups").child(code);

      // Get user name
      Global.getUserName().then((username) {
        joinGroupDb.child("members").once().then((DataSnapshot snapshot) {
          // Ensure not joined yet
          if (snapshot.value != null && snapshot.value[user.uid] != null) {
            MyTheme.alertMsg(
                context, "Already joined", "You are already in this group");
          } else {
            joinGroupDb.child('members').update({
              user.uid: {
                "email": user.email,
                "stepCountWhenJoined": Global.stepCount,
                "name": username,
                "role" : "member",
              },
            });
            successfulMsg(
                context, "Joined", "You joined the group successfully");
          }

          // Update user's groupList
          FirebaseAuth.instance.currentUser().then((user) {
            FirebaseDatabase.instance
                .reference()
                .child("member")
                .child(user.uid)
                .child("groups")
                .update({
              code: code,
            });
          });
        });
      });
    } else {
      MyTheme.alertMsg(
          context, "Wrong Group Code ", "Group doesn't exist, Try again.");
    }
  }

  static Widget successfulMsg(BuildContext context, String title, String desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            height: 350,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 0.0, 10.0),
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
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 0.0, 50.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
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
                                        MediaQuery.of(context).size.width *
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
        );
      },
    );
  }
}
