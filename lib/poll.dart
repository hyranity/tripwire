import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinycolor/tinycolor.dart';

import 'Model/MyTheme.dart';

class PollPage extends StatefulWidget {
  @override
  _PollPage createState() => _PollPage();
}

class _PollPage extends State<PollPage> {
  @override
  Widget build(BuildContext context) {
   //Main UI
    return Scaffold(
      body: new GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      alignment: Alignment.centerLeft,
                      child: MyTheme.backButton(context)),
                  SizedBox(
                    //Provide responsive design
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Poll",
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontSize: 35,
                              color: TinyColor.fromString("#de6676").darken(35).color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ), //Title
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Ask a quick question from everyone",
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: TinyColor.fromString("#de6676").darken(35).color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ), //Description
                        SizedBox(
                          //Provide responsive design
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        TextField(
                          autocorrect: true,
                          maxLines: 3,
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: "Question",
                            labelStyle: TextStyle(
                              color:  TinyColor.fromString("#de6676").darken(45).color,
                              fontSize: 20,
                            ),
                          ),
                          style: TextStyle(
                            height:2.0,
                            color:Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),



                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}