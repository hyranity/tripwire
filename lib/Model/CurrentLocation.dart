import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class CurrentData{
  static Future<Placemark> place = loadLocation();
  static double latitude;
  static double longitude;
  static final weatherAPIkey = "343fa72db5da0ba76765d13863c47df3";
  static final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  static Future<Weather> weather;

  static Future<Placemark> loadLocation(){
    // Code possible thanks to https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin


    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position currentPos) async {
      try {
        List<Placemark> placeList = await geolocator.placemarkFromCoordinates(currentPos.latitude, currentPos.longitude);


          CurrentData.latitude = currentPos.latitude;
          CurrentData.longitude = currentPos.longitude;


          return placeList[0];

      } catch (error) {
        print(error);
      }
    }).catchError((error) {
      print(error);
    });
  }

  static Future<Weather> getWeather() async{
    WeatherFactory wf = new WeatherFactory(weatherAPIkey);
    return await wf.currentWeatherByLocation(latitude, longitude);
  }

}