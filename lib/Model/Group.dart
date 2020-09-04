import 'package:tripwire/Model/MyTheme.dart';

class Group{
  String name;
  String id;
  int hoursSince;
  bool isActive;
  int memberCount;
  String desc;
  String photoURL;

  Group(
      {this.name,
      this.id,
      this.hoursSince = 1,
      this.isActive = false,
      this.memberCount = 0,
      this.desc,
      this.photoURL = "MyTheme.defaultIcon"});
}
