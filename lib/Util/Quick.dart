import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

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
}
