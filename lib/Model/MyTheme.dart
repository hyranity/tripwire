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

  static Widget alertMsg(BuildContext context, String title, String desc) {
    showDialog(
      context:context,
      builder: (BuildContext context){
        return Dialog(
          shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          child: Container(
            height: 350,
            child: Column(
              children: <Widget> [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0 ,15.0 ,0.0 ,10.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,

                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0 ,15.0 ,0.0 ,50.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      desc,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                        decoration: BoxDecoration(
                            color: Color(0xffB5E8AF),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.grey.withOpacity(0.1),
                            )
                          ]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.check,
                                  color: Color(0xff537050),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Okay",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13 + MediaQuery.of(context).size.width * 0.014,
                                    color: Color(0xff537050),
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

//Code possible thanks to https://stackoverflow.com/questions/51119795/how-to-remove-scroll-glow
class NoGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
