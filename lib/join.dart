import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      joinGroupDb.child("members").once().then((DataSnapshot snapshot) {
        // Ensure not joined yet
        if (snapshot.value[user.uid] != null) {
          MyTheme.alertMsg(
              context, "Already joined", "You are already in this group");
        } else {
           joinGroupDb.child('members').update({
            user.uid: user.email,
          });
          MyTheme.alertMsg(
              context, "Joined", "You joined the group successfully");
        }
      });
    } else {
      MyTheme.alertMsg(
          context, "Wrong Group Code ", "Group is not Found, Try again.");
    }
  }
}
