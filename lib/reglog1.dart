//import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'auth_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'provider_widget.dart';

final primaryColor = Color(444444);

enum AuthFormType { signIn, signUp, reset}

class SignUpView extends StatefulWidget {
  final AuthFormType authFormType;

  SignUpView({Key key, @required this.authFormType}) : super(key: key);

  @override
  _SignUpViewState createState() =>
      _SignUpViewState(authFormType: this.authFormType);
}

class _SignUpViewState extends State<SignUpView> {
  AuthFormType authFormType;
  bool isload = false;

  @override
  void initState() {
    super.initState();
  }

  _SignUpViewState({this.authFormType});

  final formKey = GlobalKey<FormState>();
  String _email, _password, _name, _warning, _phone;

  void switchFormState(String state) {
    formKey.currentState.reset();
    if (state == "signUp") {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else if (state == 'home') {
      Navigator.of(context).pop();
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

  bool validate() {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      setState(() {
        isload = true;
      });
      try {
        final auth = Provider.of(context).auth;
        switch (authFormType) {
          case AuthFormType.signIn:
            await auth.signInWithEmailAndPassword(_email.trim(), _password);
            final String name1 = FirebaseAuth.instance.currentUser.displayName;
            Navigator.of(context).pushReplacementNamed('/home');
            print(name1);
            break;
          case AuthFormType.signUp:
            await auth.createUserWithEmailAndPassword(_email.trim(), _password, _name);
            final String id = FirebaseAuth.instance.currentUser.uid;
            FirebaseFirestore.instance.collection('Users').doc(id).set({
              'id' : id,
              'name': _name,
              'email': _email,
              'timestamp': DateTime.now(),
              'url': null
            });
            final String name = FirebaseAuth.instance.currentUser.displayName;
            print(name);
            print(id);
            Navigator.of(context).pushReplacementNamed('/home');
            break;
          case AuthFormType.reset:
            await auth.sendPasswordResetEmail(_email.trim());
            setState(() {
              _warning = "A password reset link has been sent to $_email";
              authFormType = AuthFormType.signIn;
            });
            break;
        }
      } catch (e) {
        setState(() {
          _warning = e.message;
          setState(() {
            isload = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [HexColor('#222222'),HexColor('#666666')])),
            //color: primaryColor,
            height: _height,
            width: _width,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  SizedBox(height: _height * 0.025),
                  showAlert(),
                  SizedBox(height: _height * 0.025),
                  buildHeaderText(),
                  SizedBox(height: _height * 0.05),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: buildInputs() + buildButtons(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget showAlert() {
    if (_warning != null) {
      return Container(
        color: Colors.white,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline,color: Colors.black54,),
            ),
            Expanded(
              child: AutoSizeText(
                _warning,
                maxLines: 3,
                style: GoogleFonts.montserrat(color: Colors.black54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close,color: Colors.black54,),
                onPressed: () {
                  setState(() {
                    _warning = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  AutoSizeText buildHeaderText() {
    String _headerText;
    if (authFormType == AuthFormType.signIn) {
      _headerText = "Sign In";
    } else if (authFormType == AuthFormType.reset) {
      _headerText = "Reset Password";
    } else {
      _headerText = "Sign Up";
    }
    return AutoSizeText(
      _headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(fontSize: 30,color: Colors.white)
    );
  }

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      _phone = internationalizedPhoneNumber;
    });
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    // if were in the sign up state add name
    if ([AuthFormType.signUp].contains(authFormType)) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: GoogleFonts.montserrat(fontSize: 20,color: Colors.black),
          decoration: buildSignUpInputDecoration("Name"),
          onSaved: (value) => _name = value,
        ),
      );
      textFields.add(SizedBox(height: 20));
    }

    if ([
      AuthFormType.signUp,
      AuthFormType.reset,
      AuthFormType.signIn
    ].contains(authFormType)) {
      textFields.add(
        TextFormField(
          validator: EmailValidator.validate,
          style: GoogleFonts.montserrat(fontSize: 20,color: Colors.black),
          decoration: buildSignUpInputDecoration("Email"),
          onSaved: (value) => _email = value,
        ),
      );
      textFields.add(SizedBox(height: 20));
    }

    if (authFormType != AuthFormType.reset) {
      textFields.add(
        TextFormField(
          validator: PasswordValidator.validate,
          style: GoogleFonts.montserrat(fontSize: 20,color: Colors.black),
          decoration: buildSignUpInputDecoration("Password"),
          obscureText: true,
          onSaved: (value) => _password = value,
        ),
      );
      textFields.add(SizedBox(height: 20));
    }
    return textFields;
  }

  InputDecoration buildSignUpInputDecoration(String hint) {
    return InputDecoration(
      errorStyle: GoogleFonts.montserrat(fontSize: 11,color: Colors.white),
      border: InputBorder.none,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.0)),
      contentPadding:
      const EdgeInsets.only(left: 14.0, bottom: 10.0, top: 10.0),
    );
  }

  List<Widget> buildButtons() {
    String _switchButtonText, _newFormState, _submitButtonText;
    bool _showForgotPassword = false;
    bool _showSocial = true;

    if (authFormType == AuthFormType.signIn) {
      _switchButtonText = "Sign Up";
      _newFormState = "signUp";
      _submitButtonText = "Sign In";
      _showForgotPassword = true;
    } else if (authFormType == AuthFormType.reset) {
      _switchButtonText = "Return to Sign In";
      _newFormState = "signIn";
      _submitButtonText = "Submit";
      _showSocial = false;
    }
    else {
      _switchButtonText = "Sign In";
      _newFormState = "signIn";
      _submitButtonText = "Sign Up";
    }

    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          color: Colors.white,
          textColor: HexColor('#444444'),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _submitButtonText,
              style: GoogleFonts.montserrat(fontSize: 20,fontWeight: FontWeight.w300),
            ),
          ),
          onPressed: isload ? null : submit,
        ),
      ),
      showForgotPassword(_showForgotPassword),
      OutlineButton(
        borderSide: BorderSide(color: Colors.white),
        highlightedBorderColor: Colors.white,
        child: Text(
          _switchButtonText,
            style: GoogleFonts.montserrat(fontSize: 17,color: Colors.white),
        ),
        onPressed: () {
          switchFormState(_newFormState);
        },
      ),
      //buildSocialIcons(_showSocial),
    ];
  }

  Widget showForgotPassword(bool visible) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Visibility(
        child: GestureDetector(
          onTap: () {
            setState(() {
              authFormType = AuthFormType.reset;
            });
          },
          child: Container(
            child: Text(
              "Forgot Password?",
                style: GoogleFonts.montserrat(color: Colors.white,decoration: TextDecoration.underline,fontSize: 16),
            ),
          ),
        ),
        visible: visible,
      ),
    );
  }
}