import 'dart:convert';

import 'package:http/http.dart';
import 'package:intl/intl.dart';

class WorldTime {
  String time;
  DateTime worldtime;
  String url;

  WorldTime({this.url});

  Future<void> getTime() async {
    try{
      Response response = await get('http://worldtimeapi.org/api/timezone/$url');
      Map data = jsonDecode(response.body);

      //get prroperties from the Map data
      String datetime = data['datetime'];
      String offset = data['utc_offset'].substring(1,3);

      //Convert string datetime to date object
      DateTime now = DateTime.parse(datetime);
      print('Date time now : $now');
      now = now.add(Duration(hours: int.parse(offset)));
      worldtime = now;

      //set the time property
      time = DateFormat.jm().format(now);
    }
    catch(ex) {
      print('error : $ex');
      time = "Could not get time data";
    }
  }

  Future<bool> calcTimeDiff(String now, String before) async{
    try {
      print('now : $now');
      print('before : $before');
      DateTime current = DateTime.parse(now);
      DateTime previous = DateTime.parse(before);

      Duration diff = current.difference(previous);
      if(diff.inMinutes > 0)
        return true;
      else return false;
    }
    catch(ex){
      print('ERROR :  $ex');
    }
  }


}