import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class Quick{
  static Widget makeText(String text, int color, double size, {FontWeight fontWeight = FontWeight.w500}){
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Color(color),
        fontWeight: fontWeight,
        fontSize: size
      )
    );
  }



}