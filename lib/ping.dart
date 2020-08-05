import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:tripwire/Model/MyTheme.dart';
import 'Util/DB.dart';


class PingPage extends StatefulWidget {
  @override
  _PingPage createState() => _PingPage();
}

class _PingPage extends State<PingPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:Center(
        child:Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Container(
            child: Column (
              children: <Widget> [
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

  Widget MemberList() {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
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

  Future<List> getMemberArray() async {

    var db =  FirebaseDatabase.instance.reference().child("groups").child("1").child("members");

    // Return the data obtained from db
    return db.once().then((DataSnapshot snapshot){

      //List to hold member data
      List memberList = new List();

      // HashMap to store DB data
      Map<dynamic, dynamic> members = snapshot.value;

      //Get each member from DB and put into list
      members.forEach((key, value) {
        memberList.add(value);
      });

      // Return the data to the above return
      return memberList;
    });
  }


  Widget MemberItem(data) {
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
                data,
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
      );
  }

  Widget MemberListWidget() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.37,
      child: FutureBuilder<List>(
        future: getMemberArray(),

        builder: (BuildContext context, AsyncSnapshot<List> snapshot){
          if (snapshot.connectionState != ConnectionState.done && !snapshot.hasData ) {
            print("hello1");
            return new CircularProgressIndicator();
          }
          print("finished " + snapshot.data.toString());
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
                print("hello3");
                return MemberItem(snapshot.data[index]);
              }
            ),
          );
        }),
    );
  }

}