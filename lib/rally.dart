

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'Model/MyTheme.dart';
import 'Model/world_time.dart';
import 'Util/Quick.dart';

class RallyPage extends StatefulWidget {
  RallyPage({Key key, @required this.id}) : super(key: key);
  final String id;
  @override
  _RallyPage createState() => _RallyPage();
}

class _RallyPage extends State<RallyPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

  }

  Future<FirebaseUser> RallyEvent() async {
    var date = DateTime.now();
    var eventDb = FirebaseDatabase.instance.reference().child("groups").child(widget.id).child("events").child(date.day.toString() + "-" + date.month.toString() + "-" + date.year.toString());
    final FirebaseUser user = await auth.currentUser();


    Quick.getLocation().then((myLocation) {
      String locationRally = myLocation.subLocality + ", " + myLocation.locality;

      eventDb.push().set({
        'title': 'Rally Everyone',
        'sender': user.uid,
        'receiver': 'all',
        'groupId': widget.id,
        'type': 'rally',
        'isReplied': 'no',
        'location' : locationRally,
        'sentTime': DateTime.now().toString(),
      });
    });

    MyTheme.alertMsg(context, "Rally ", "You have noticed all your group member to rally");
  }
}


