

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'Model/MyTheme.dart';
import 'Model/world_time.dart';

class RallyPage extends StatefulWidget {
  @override
  _RallyPage createState() => _RallyPage();
}

class _RallyPage extends State<RallyPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

  }

  Future<FirebaseUser> ComeEvent(String time) async {
    var eventDb = FirebaseDatabase.instance.reference().child("events");
    final FirebaseUser user = await auth.currentUser();
    bool spamDiscovered = false;

    //get time
    WorldTime wt = WorldTime(url: 'Asia/Kuala_Lumpur');
    await wt.getTime();

    //Check if sender rally after 5 minutes
    await eventDb.once().then((DataSnapshot snapshot) async{
      Map<dynamic, dynamic> events  = snapshot.value;
      if(events != null) {
        events.forEach((eventKey, eventValue) async {
          if (await wt.calcTimeDiff(wt.worldtime.toString(), eventValue['sentTime']) && eventValue['sender'] == user.uid) {
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

    if (spamDiscovered == true) {
      MyTheme.alertMsg(context, 'Failed to Rally', 'Rally everyone again in 5 minutes. ');
    }
    else if(spamDiscovered == false) {
      eventDb.push().set({
        'title' : 'Rally Everyone',
        'sender' : user.uid,
        'receiver' : 'all',
        'type' : 'rally',
        'sentTime' : wt.worldtime.toString(),
      });
    }

  }
}


