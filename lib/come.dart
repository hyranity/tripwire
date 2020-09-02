

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Model/Member.dart';
import 'Model/MyTheme.dart';
import 'Model/world_time.dart';

class ComePage extends StatefulWidget {
  ComePage({Key key, @required this.id}) : super(key: key);
  final String id;

  @override
  _ComePage createState() => _ComePage();
}

class _ComePage extends State<ComePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final List<String> list = new List();

  @override
  Widget build(BuildContext context) {
    loadMemberList();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top:60),
          child: Container(
            child: Column (
              children: <Widget>[
                Container (
                    padding: EdgeInsets.only(left: 20, right: 20),
                    alignment: Alignment.centerLeft,
                    child: MyTheme.backButton(context),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                ),
                MemberList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loadMemberList() {
    setState(() {
      var groupDb = FirebaseDatabase.instance.reference().child("groups").child(widget.id).child("members");
      groupDb.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> groups = snapshot.value;
        groups.forEach((key, value) {
          list.add(key);
        });
      });
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
                style: MyTheme.sectionHeader(context)
            ),
          ),
          MemberListWidget(),
        ],
      ),
    );
  }

  Future<List<Member>> getMemberArray() async {

    var db =  FirebaseDatabase.instance.reference().child("member");
    final FirebaseUser user = await auth.currentUser();

    // Return the data obtained from db
    return db.once().then((DataSnapshot snapshot){

      //List to hold member data
      List<Member> memberList = new List();

      // HashMap to store DB data
      Map<dynamic, dynamic> members = snapshot.value;

      //Get each member from DB and put into list
      members.forEach((key, value) {
        for (int i=0 ; i<list.length ; i++) {
          if(list[i] == key) {
            // For each member
            if (value['name'] != user.displayName.trim())
              memberList.add(
                  new Member(name: value["name"], email: value["email"]));
          }
        }
      });

      // Return the data to the above return
      return memberList;
    });
  }

  Widget MemberItem(Member member) {
    return InkWell(
      onTap: () {
        ComeEvent(member.name);
      },
      child: Container(
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
              Container(
                height: 40,
                width: 40,
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
                  ),
                ),
              ),
            ],
          ),
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

  Future<FirebaseUser> ComeEvent(String name) async {
    var date = DateTime.now();
    var memberDb = FirebaseDatabase.instance.reference().child("member");
    var eventDb = FirebaseDatabase.instance.reference().child("groups").child(widget.id).child("events").child(date.day.toString() + "-" + date.month.toString() + "-" + date.year.toString());
    final FirebaseUser user = await auth.currentUser();
    bool spamDiscovered = false;

    //get time
    WorldTime instance = WorldTime(url: 'Asia/Kuala_Lumpur');
    await instance.getTime();

    //Check if sender ping after 5 minutes
    await eventDb.once().then((DataSnapshot snapshot) async{
      Map<dynamic, dynamic> events  = snapshot.value;
      if(events != null) {
        events.forEach((eventKey, eventValue) async {
          if (await instance.calcTimeDiff(instance.worldtime.toString(), eventValue['sentTime']) && eventValue['sender'] == user.uid || eventValue['type'] != "come" || eventValue['senderName'] != name ) {
            //if not spamming within 5 minutes, create a ping event
            print("Not Spamming");
          }
          else {
            print("Spam");
            spamDiscovered = true;
          }
        });
      }
    });

    print('Spam : $spamDiscovered');

    //if spam within 5 minutes
    if (spamDiscovered == true) {
      MyTheme.alertMsg(context, 'Failed to Summon', 'Summon again in 5 minutes. ');
    }
    else if (spamDiscovered == false) {
      memberDb.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> members = snapshot.value;

        members.forEach((key, value) {
          if (value['name'] == name) {
            eventDb.push().set({
              'title': 'Summoning  ' + name,
              'sender': user.uid,
              'senderName' : name,
              'receiver': key,
              'triggerPerson' : user.displayName.trim(),
              'groupId' : widget.id,
              'type': 'come',
              'isReplied' : 'no',
              'sentTime': instance.worldtime.toString(),
            });
          }
        });
      });
      MyTheme.alertMsg(context, "Summoning", "Your request has been sent");
    }
  }

}

