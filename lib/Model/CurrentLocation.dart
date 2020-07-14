import 'package:geolocator/geolocator.dart';

class CurrentLocation{
  static Placemark place = getLocation();
  static final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  static Placemark getLocation() {
    // Code possible thanks to https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin


    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position currentPos) async{
      try{
        List<Placemark> placeList = await geolocator.placemarkFromCoordinates(currentPos.latitude, currentPos.longitude);
        Placemark place = placeList[0];
        print("got place");
        return place;
      }catch(error){
        print(error);
      }
    }).catchError((error) {
      print(error);
    });
  }

//  static getAddress() async{
//    try{
//      List<Placemark> placeList = await geolocator.placemarkFromCoordinates(currentPos.latitude, currentPos.longitude);
//      Placemark place = placeList[0];
//
//      setState((){
//        CurrentLocation.place = place;
//      });
//    }catch(error){
//      print(error);
//    }
//  }
}