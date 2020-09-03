import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwire/Util/Quick.dart';
import 'package:tripwire/main.dart';
import 'package:tripwire/register.dart';

import 'Model/MyTheme.dart';



class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {

 //Check if  logged in
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        print("user is logged in");
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MyHomePage()
        ));
        print("guest detected");
        return;
      }
    });

    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            loginSection(),
            registerButton(),
          ],
        ),
      ),
    );
  }

  Widget loginSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Login",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Color(0xff669260),
            fontSize: 35,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 20
        ),
        Container(
          width: Quick.getDeviceSize(context).width * 0.8,
          decoration: BoxDecoration(
            color: Color(0xffA3D89F),
            borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 5),
                  color: Colors.grey.withOpacity(0.3),
                )
              ]
          ),
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              contentPadding:EdgeInsets.fromLTRB(10,0,10,0),
                labelText: 'EMAIL',
              border: InputBorder.none,
              focusColor: Colors.red,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
            height: 10
        ),
        Container(
          width: Quick.getDeviceSize(context).width * 0.8,
          decoration: BoxDecoration(
            color: Color(0xffA3D89F),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 5),
                color: Colors.grey.withOpacity(0.3),
              )
            ]
          ),

          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              contentPadding:EdgeInsets.fromLTRB(10,0,10,0),
              labelText: 'PASSWORD',
              border: InputBorder.none,
              focusColor: Colors.red,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
            height: 24
        ),
        Container(
          decoration: BoxDecoration(
              color: Color(0xffD5F5D1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  blurRadius: 15,
                  color: Colors.grey.withOpacity(0.3),
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                signInUser(emailController.text, passwordController.text)
                    .then((FirebaseUser user) {
                  Quick.navigate(context, () => MyHomePage());
                }).catchError((e) => MyTheme.alertMsg(context, "Login Failed", "Email or Password is incorrect, Please try again."),);
              },
              child: Text(
                "LET'S GO",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff669260),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget registerButton() {
    return Positioned(
      bottom: 35,
      child: InkWell(
        onTap: (){
          Quick.navigate(context, () => Register());
        },
        child: Text(
          "REGISTER >",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xff90C78A),
          ),
        ),
      ),
    );
  }

  Future<FirebaseUser> signInUser(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    final FirebaseUser user = result.user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      print('signInEmail succeeded: $user');

      return user;

  }
}

