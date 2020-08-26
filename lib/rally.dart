

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

  Future<FirebaseUser> RallyEvent() async {
    var eventDb = FirebaseDatabase.instance.reference().child("events");
    final FirebaseUser user = await auth.currentUser();

    //get time
    WorldTime wt = WorldTime(url: 'Asia/Kuala_Lumpur');
    await wt.getTime();

    await eventDb.push().set({
      'title' : 'Rally Everyone',
      'sender' : user.uid,
      'receiver' : 'all',
      'type' : 'rally',
      'sentTime' : wt.worldtime.toString(),
    });

    MyTheme.alertMsg(context, "Rally ", "You have noticed all your group member to rally");
  }
}


