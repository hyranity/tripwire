import 'package:firebase_database/firebase_database.dart';

class DB{
  static FirebaseDatabase db(){
    return FirebaseDatabase.instance;
  }

  // Usage
//  DB.get(DB.db().reference().child("user").child("Kelvin")).then((var value){
//  print(value["name"]); //Prints 'Kelvin'
//  });
  static get(DatabaseReference reference){
    return reference.once().then((DataSnapshot snap){
      return snap.value;
    });
  }

  // Usage
  // DB.insert(DB.db().reference().child("user").child("Kelvin"), {"name": "Kelvin", "pp": "small"});
  static insert(DatabaseReference reference, Map map){
    reference.set(map);
  }

  // Usage
  // DB.remove(DB.db().reference().child("user").child("Kelvin"));
  static remove(DatabaseReference reference){
    reference.remove();
  }
}