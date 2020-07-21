import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwire/Util/Quick.dart';

class MyTheme {
  static Color primaryColor = Color(0xffD5F5D1);
  static Color accentColor = Color(0xff669260);

  static TextStyle sectionHeader(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 15 + MediaQuery.of(context).size.width * 0.014,
      color: Color(0xff90C78A),
      fontWeight: FontWeight.w700,
    );
  }

  static Widget backButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18),
      child: InkWell(
        onTap: () {
          Quick.goBack(context);
        },
        child: Column(
          children: <Widget>[
            Text(
              "< BACK",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20 + MediaQuery.of(context).size.width * 0.014,
                color: Color(0xff669260),
              ),
            ),
            SizedBox(
              //Provide responsive design
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
