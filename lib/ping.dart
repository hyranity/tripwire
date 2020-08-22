import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:tripwire/Model/MyTheme.dart';
import 'package:tripwire/Model/world_time.dart';
import 'Model/Member.dart';


class PingPage extends StatefulWidget {
  PingPage({Key key, @required this.id}) : super(key: key);

  final String id;

  @override
  _PingPage createState() => _PingPage();

}

class _PingPage extends State<PingPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final List<String> list = new List();

  @override
  Widget build(BuildContext context) {
    //load member in group into an array
    loadMemberList();
    return Scaffold(
      body:Center(
        child:Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Container(
            child: Column (
              children: <Widget> [
                Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    alignment: Alignment.centerLeft,
                    child: MyTheme.backButton(context)),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                ),
                MemberList(),
              ],
            ) ,
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

  //The list view + member
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
    var groupDb = FirebaseDatabase.instance.reference().child("groups").child(widget.id).child("members");
    final FirebaseUser user = await auth.currentUser();


    return db.once().then((DataSnapshot snapshot){
      List<Member> memberList = new List();

      Map<dynamic, dynamic> members = snapshot.value;

        members.forEach((key, value) {
          for (int i=0 ; i<list.length ; i++) {
            if(list[i] == key) {
              if (value['name'] != user.displayName.trim())
                memberList.add( new Member(name: value["name"], email: value["email"]));
            }
          }
        });

      return memberList;
    });

  }

  //member item
  Widget MemberItem(Member member) {
    return InkWell(
      onTap: () {
        PingEvent(member.name);
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

  Widget RequestingWidget() {

  }

  Future<FirebaseUser> PingEvent(String name) async {
    var memberDb = FirebaseDatabase.instance.reference().child("member");
    var eventDb = FirebaseDatabase.instance.reference().child("events");
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
          if (await instance.calcTimeDiff(instance.worldtime.toString(), eventValue['sentTime']) && eventValue['sender'] == user.uid || eventValue['type'] != "ping" || eventValue['senderName'] != name) {
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
      MyTheme.alertMsg(context, 'Failed to Ping', 'Ping again in 5 minutes. ');
    }
    else if (spamDiscovered == false) {
      memberDb.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> members = snapshot.value;

        members.forEach((key, value) {
          if (value['name'] == name) {
            eventDb.push().set({
              'title': 'Ping to ' + name,
              'sender': user.uid,
              'senderName' : name,
              'receiver': key,
              'groupId' : widget.id,
              'type': 'ping',
              'sentTime': instance.worldtime.toString(),
            });
          }
        });
      });
      MyTheme.alertMsg(context, "Ping Success ", "Your ping request has been sent successfully");
    }
  }
}

