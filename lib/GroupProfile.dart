
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwire/main.dart';

import 'Model/Group.dart';
import 'Model/Member.dart';
import 'Model/MyTheme.dart';
import 'Util/Quick.dart';

class GroupProfile extends StatefulWidget {
  GroupProfile({Key key, @required this.group}) : super(key: key);
   Group group;

  @override
  _GroupProfile createState() => _GroupProfile();
  
}

class _GroupProfile extends State<GroupProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;
  Group group;

  int retryConnect = 0;
  int totalMembers = 0;
  int buildTimes = 0;
  final List<String> list = new List();

  @override
  void loadGroupData() {
    setState(() {
      group = widget.group;
      countUser();
    });
  }

  void loadMemberList() {
    setState(() {
      var groupDb = FirebaseDatabase.instance.reference().child("groups").child(group.id).child("members");
      groupDb.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> groups = snapshot.value;
        groups.forEach((key, value) {
          list.add(key);
        });
      });
    });
  }

  void countUser() async {
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
      group.memberCount = countUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (group == null && retryConnect < 5) {
      retryConnect++;
      print("Getting group data.... try #" + retryConnect.toString());
      loadGroupData();
      loadMemberList();
    }

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * .45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [MyTheme.primaryColor, Colors.green],
                ),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://cache.desktopnexus.com/thumbseg/1847/1847388-bigthumbnail.jpg"
                              ),
                      radius: 50.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      group.name,
                      style: GoogleFonts.poppins(
                        fontSize: 25.0,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * .55,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Group Name",
                        style: GoogleFonts.poppins(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          color: Color(0xff669260),
                        ),
                      ),
                      Text(
                        group.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          decoration: TextDecoration.none,
                          color:  Color(0xff8FBF88),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Description",
                        style: GoogleFonts.poppins(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          color: Color(0xff669260),
                        ),
                      ),
                      Text(
                        group.desc,
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          decoration: TextDecoration.none,
                          color:  Color(0xff8FBF88),
                        ),
                      ),
                      SizedBox(
                        height: Quick.getDeviceSize(context).height * 0.05,
                      ),
                      Container (
                        alignment: Alignment.bottomCenter,
                        child: RaisedButton(
                          onPressed: () {
                            QuitGroup();
                          },
                          shape: RoundedRectangleBorder (
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [Colors.red,Colors.redAccent]
                              ),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: Quick.getDeviceSize(context).width, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text("Quit Group",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 26.0, fontWeight:FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        ),
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(
              top: MediaQuery
                  .of(context)
                  .size
                  .height * .35,
              right: 20.0,
              left: 20.0),
          child: Container(
            height: 120.0,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 22.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {memberListPopUp();},
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Members",
                              style: GoogleFonts.poppins(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff669260),
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              group.memberCount.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 15.0,
                                color:  Color(0xff8FBF88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Group Code",
                            style: GoogleFonts.poppins(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff669260),
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            group.id,
                            style: GoogleFonts.poppins(
                              fontSize: 15.0,
                              color:  Color(0xff8FBF88),
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
        ) //Card
      ],
    );
  }

  Widget memberListPopUp() {
    showModalBottomSheet(
        barrierColor: Color.fromRGBO(0, 0, 0, 0.01),
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: Quick.getDeviceSize(context).height * 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white60],
              ),
                color: Colors.blueAccent,
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
                  MemberList(),
                ],
              ),
            ),
          );
        });
  }

  Future<List<Member>> getMemberArray() async {

    var db =  FirebaseDatabase.instance.reference().child("member");

    return db.once().then((DataSnapshot snapshot){
      List<Member> memberList = new List();

      Map<dynamic, dynamic> members = snapshot.value;

      members.forEach((key, value) {
        for (int i=0 ; i<list.length ; i++) {
          if(list[i] == key) {
            memberList.add( new Member(name: value["name"], email: value["email"]));
          }
        }
      });

      return memberList;
    });

  }

  Widget MemberList() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
                "Members",
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
            ),
          ),
          MemberListWidget(),
        ],
      ),
    );
  }

  Widget MemberItem(Member member) {
    return Container(
      height:70,
      decoration: BoxDecoration(
          color: Color(0xff6098F6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              offset: Offset(0, 7),
              color: Colors.grey.withOpacity(0.6),
            )
          ]),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon (
              Icons.face,
              color: Colors.white70,
              size: 30,
            ),

            SizedBox(
              width: 16,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                member.name,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget MemberListWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.37,
        child: FutureBuilder<List<Member>>(
            future: getMemberArray(),

            builder: (BuildContext context, AsyncSnapshot snapshot){

              // While data is loading
              if (snapshot.connectionState != ConnectionState.done) {
                return new Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }

              // If no members
              if(!snapshot.hasData){
                return new Container(
                  child: Text(
                      "No members found."
                  ),
                );
              }

              // If members are found and retrieved successfully
              return MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    separatorBuilder: (BuildContext context, int index){
                      return SizedBox(
                        height: 15,
                      );
                    },
                    itemBuilder: (BuildContext context, int index){
                      return MemberItem(snapshot.data[index]);
                    }
                ),
              );
            }),
      ),
    );
  }

  QuitGroup() async {
    final FirebaseUser user = await auth.currentUser();
    var delGroupDb = FirebaseDatabase.instance.reference().child("groups").child(group.id).child("members");
    var updateGroupJoinedDb = FirebaseDatabase.instance.reference().child("member").child(user.uid).child("groups");

    await delGroupDb.child(user.uid).remove();
    await updateGroupJoinedDb.child(group.id).remove();

    Quick.navigate(context, () => MyHomePage());
    MyTheme.alertMsg(context, "Success", "You have quit the group. Sad");
  }
  
}