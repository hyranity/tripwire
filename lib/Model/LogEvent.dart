import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class LogEvent{
  String eventID;
  String title;
  String triggerPerson;
  DateTime sentTime;
  String type;
  bool isCommunication;
  LogEvent({this.title = "Event X", this.triggerPerson = "John Doe", this.type = "location", this.sentTime = null, this.isCommunication = false});

  //Returns an icon based on its type
  static Widget getIcon(String type, double size){
    IconData icon = Icons.error_outline;
    Color iconColor = LogEvent.getColorScheme(type, false, 0); // No lightening or darkening

    //Whether location or communication type of event, put your icon here
    switch(type){
      case "location":
        icon = Icons.location_on;
        break;
      case "rally":
        icon = Icons.assistant_photo;
        break;
      case "ping":
        icon = Icons.my_location;
        break;
      case "summon":
        icon = Icons.pan_tool ;
        break;
      case "poll":
        icon = Icons.question_answer ;
        break;
    }

    return Icon(
      icon,
      color: iconColor,
      size: size,
    );
  }

  //Returns a color scheme based on type
  static Color getColorScheme(String type, bool isLighten, int value){
    String iconColor = "A1C7EE";
    //Whether location or communication type of event, put your color scheme here
    switch(type){
      case "location":
        iconColor = "A1C7EE";
        break;
      case "rally":
        iconColor = "F6C860";
        break;
      case "ping":
        iconColor = "6098F6";
        break;
      case "summon":
        iconColor = "9874ed";
        break;
      case "poll":
        iconColor = "de6676";
    }

    return isLighten ? TinyColor.fromString("#" + iconColor).lighten(value).color : TinyColor.fromString("#" + iconColor).darken(value).color;
  }

  timeSinceSet(){
    int difference = DateTime.now().difference(sentTime).inMinutes;

    if(difference > 60){
      // Hour
      double hour = difference / 60;
      if(hour<24){
        return hour.floor().toString() + (hour<2? " hr " : " hrs ") + " ago";
      }

      //Days
      double days = hour / 24;
      if(days<7){
        return days.floor().toString() + (days<2? " day " : " days ") + " ago";
      }

      //Weeks
      double weeks = days / 7;
      if(weeks<4){
        return weeks.floor().toString() + (weeks<2? " wk " : " wks ") + " ago";
      }

      //Weeks
      double months = weeks / 4;
      if(months<12){
        return months.floor().toString() + (months<2? " mth " : " mths ") + " ago";
      }

      //Weeks
      double years = months / 12;
      return years.floor().toString() + (years<2? " yr " : " yrs ") + " ago";
    }else{

      //If less than 10 minutes ago
      if(difference < 10)
        return "Just now";
      else
        return difference.floor().toString() + " mins ago";
    }

  }

}