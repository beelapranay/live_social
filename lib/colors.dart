import 'package:flutter/material.dart';

class CustomColors {
  Brightness brightness;
  Color text1, primary;

  CustomColors(Brightness brightness) {
    this.brightness = brightness;

    if(brightness == Brightness.dark) {
      this.text1 = Colors.white;
      this.primary = Colors.black;

    } else {
      this.text1 = Colors.black;
      this.primary = Colors.white;
    }
  }

}