import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class FirstView extends StatelessWidget {
  final primaryColor = Hexcolor('#444444');

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Hexcolor('#222222'),Hexcolor('#666666')])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: _height * 0.10),
                Text(
                  "SRET Social",
                  style: GoogleFonts.montserrat(fontSize: 40),
                ),
                SizedBox(height: _height * 0.10),
                AutoSizeText(
                  "A breathtaking community to dive in.",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 30)
                ),
                SizedBox(height: _height * 0.15),
                RaisedButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                    child: Text(
                      "New to the community? Sign Up",
                      style: GoogleFonts.montserrat(fontSize: 17,fontWeight: FontWeight.w300,color: primaryColor)
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/signUp');
                  },
                ),
                SizedBox(height: _height * 0.05),
                OutlineButton(
                  borderSide: BorderSide(color: Colors.white),
                  highlightedBorderColor: Colors.white,
                  child: Text(
                    "Already a member? Sign In",
                      style: GoogleFonts.montserrat(fontSize: 17,color: Colors.white)
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/signIn');
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}