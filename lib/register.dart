import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwire/Util/Quick.dart';
import 'package:tripwire/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final phoneNumController = new TextEditingController();

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
            controller: phoneNumController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              labelText: 'PHONE NUMBER',
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
                signUp(emailController.text, passwordController.text, nameController.text, phoneNumController.text);
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

  Future<FirebaseUser> signUp (email, password, name, phoneNum) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    final FirebaseUser user = result.user;

    //update displayName
    UserUpdateInfo updateUser = UserUpdateInfo();
    updateUser.displayName = name;
    user.updateProfile(updateUser);

    assert (user != null);
    assert (await user.getIdToken() != null);

    final memberDatabaseRef = FirebaseDatabase().reference().child("member").child(user.uid);
    memberDatabaseRef.set({
      'email' : email.trim(),
      'name' : name.trim(),
      'phone' : phoneNum.trim()
    });

    return user;
  }
}
