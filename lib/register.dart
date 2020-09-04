import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwire/Util/Quick.dart';
import 'package:tripwire/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Model/MyTheme.dart';

class Register extends StatefulWidget {
  Register({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _Register createState() => _Register();
}

class _Register extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final nameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
          "Register",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Color(0xff669260),
            fontSize: 35,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20),
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
              ]),
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
        SizedBox(height: 10),
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
              ]),
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              labelText: 'NAME',
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

        SizedBox(height: 10),
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
              ]),
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
        SizedBox(height: 24),
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
                signUp(emailController.text, passwordController.text, nameController.text);
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
          onTap: () {
            Quick.goBack(context);
          },
          child: Text(
            "< LOGIN",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xff90C78A),
            ),
          ),
        ));
  }

  Future<FirebaseUser> signUp (email, password, name) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      final FirebaseUser user = result.user;

      //update displayName
      UserUpdateInfo updateUser = UserUpdateInfo();
      updateUser.displayName = name;
      updateUser.photoUrl =
          "https://icon-library.com/images/default-profile-icon/default-profile-icon-16.jpg";
      user.updateProfile(updateUser);

      assert (user != null);
      assert (await user.getIdToken() != null);

      final memberDatabaseRef = FirebaseDatabase().reference()
          .child("member")
          .child(user.uid);
      memberDatabaseRef.set({
        'email': email.trim(),
        'name': name.trim(),
        'photoURL': "https://icon-library.com/images/default-profile-icon/default-profile-icon-16.jpg",
      });
      successfulMsg(
          context, "Register Successful", "Your account has been registered");

    }
    catch(e) {
      switch(e.code) {
        case "ERROR_INVALID_EMAIL" :
          MyTheme.alertMsg(context, "Register Failed", "Invalid Email Format");
          break;
        case "ERROR_WRONG_PASSWORD":
          MyTheme.alertMsg(context, "Register Failed", "Wrong Password");
          break;
        case "ERROR_USER_NOT_FOUND":
          MyTheme.alertMsg(context, "Register Failed", "User is not Found");
          break;
        case "ERROR_USER_DISABLED":
          MyTheme.alertMsg(context, "Register Failed", "User is disabled");
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          MyTheme.alertMsg(context, "Register Failed", "Too many request attempt, please try again later");
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          MyTheme.alertMsg(context, "Register Failed", "Operation is not allowed");
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          MyTheme.alertMsg(context, "Register Failed", "Email in use, Please try another email.");
          break;
        case "ERROR_WEAK_PASSWORD":
          MyTheme.alertMsg(context, "Register Failed", "Weak password, password must contain atleast 6 characters");
          break;
        default:
          MyTheme.alertMsg(context, "Register Failed", e.code);
          break;
      }
    }
  }

  static Widget successfulMsg(BuildContext context, String title, String desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          child: Container(
            height: 350,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 0.0, 10.0),
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.6,
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
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 0.0, 50.0),
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.6,
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
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
                                    fontSize: 13 + MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.014,
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
