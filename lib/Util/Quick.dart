import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwire/Model/CurrentLocation.dart';
import 'package:tripwire/Model/MyTheme.dart';
import 'package:weather/weather.dart';

import 'Global.dart';

class Quick {
  static Widget makeText(String text, int color, double size,
      {FontWeight fontWeight = FontWeight.w500}) {
    return Text(text,
        style: GoogleFonts.poppins(
            color: Color(color), fontWeight: fontWeight, fontSize: size));
  }

  static void navigate(BuildContext context, Widget Function() navigatePage) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return navigatePage();
    }));
  }

  static void forceNavigate(context, Widget Function() navigatePage) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => navigatePage()),
        ModalRoute.withName('/'));
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static Size getDeviceSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static Future<Placemark> getLocation() {
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    return geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position currentPos) async {
      List<Placemark> placeList = await geolocator.placemarkFromCoordinates(
          currentPos.latitude, currentPos.longitude);

      return placeList[0];
    });
  }

  static Future<Weather> getWeather(Placemark place) {
    Weather weather;
    Geolocator geolocator = new Geolocator();
    return geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position currentPos) {
      return new WeatherFactory(CurrentData.weatherAPIkey)
          .currentWeatherByLocation(currentPos.latitude, currentPos.longitude)
          .then((Weather currentWeather) {
        weather = currentWeather;

        if (weather == null) {
          //cannot obtain by coords, try by city
          return new WeatherFactory(CurrentData.weatherAPIkey)
              .currentWeatherByCityName(place.locality)
              .then((Weather currentWeather) {
            weather = currentWeather;
            return weather;
          });
        }
        if (weather == null) {
          //cannot obtain by city, try by state
          return new WeatherFactory(CurrentData.weatherAPIkey)
              .currentWeatherByCityName(place.administrativeArea)
              .then((Weather currentWeather) {
            weather = currentWeather;
            return weather;
          });
        }

        return weather;

      });


    });
  }

  static Widget getUserPic(String uid, double radius) {
    return FutureBuilder(
      future: Global.getUserPic(uid),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return CircleAvatar(
            backgroundImage: NetworkImage(MyTheme.defaultIcon),
            radius: radius,
          );
        }

        return CircleAvatar(
          backgroundImage: NetworkImage(snapshot.data),
          radius: radius,
        );
      },
    );
  }
}
