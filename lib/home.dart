import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:project_x3/Services/posts.dart';
import 'package:project_x3/provider_widget.dart';
import 'package:project_x3/upload.dart';
import 'package:project_x3/user_profile.dart';
import 'package:project_x3/users.dart';
import 'auth.dart';
import 'package:project_x3/Services/confess.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.onSignedOut});
  final VoidCallback onSignedOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool load = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        load = false;
      });
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }


  Future<void> _signOut1(BuildContext context) async {
    try {
      final auth = Provider.of(context).auth;
      await auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text(
          'Live Social',
          style: styleb,
        ),
//          actions: <Widget>[
//            FlatButton(
//              child: Text('Log Out', style: GoogleFonts.montserrat(fontSize: 18,color: Colors.white)),
//              onPressed: () => _signOut1(context),
//            )
//          ],
      ),
      endDrawer: Container(
        child: new Drawer(
          child: Container(
            //color: Colors.white,
            child: ListView(children: <Widget>[
              new ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.red, //Hexcolor('#004e92'),
                  size: 30,
                ),
                title: new Text('User Profile',
                    style: GoogleFonts.montserrat(
                        fontSize: 20, color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new ProfileView()));
                },
              ),
              new ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.red, //Hexcolor('#004e92'),
                    size: 30,
                  ),
                  title: new Text('Log Out',
                      style: GoogleFonts.montserrat(
                          fontSize: 20, color: Colors.red)),
                  //onTap: () {},
                  onTap: () => _signOut1(context)
                  ),
            ]),
          ),
        ),
      ),
      body: Center(
        child: load
            ? Container(
                child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.red)))
            : Container(
                //color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      Align(
                        child: AutoSizeText(
                          'Select a Category',
                          minFontSize: 20,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold),
                        ),
                        alignment: Alignment.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //category("Blog"),
                      Container(
                        height: 40,
                        child: ListView(
                          shrinkWrap: true,
                          // This next line does the trick.
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            OutlineButton(
                              borderSide: BorderSide(color: Colors.red),
                              highlightedBorderColor: Colors.red,
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Posts()));
                                },
                              //height: 30,
                              child: Row(
                                children: <Widget>[
                                  Text('Blog',style: GoogleFonts.montserrat(fontSize: 14),),
                                  SizedBox(width: 5,),
                                  Icon(Icons.edit,size: 18,),
                                ],
                              ),
                            ),
                            SizedBox(width: 10,),

                            OutlineButton(
                              borderSide: BorderSide(color: Colors.red),
                              highlightedBorderColor: Colors.red,
                              onPressed: (){},
                              //height: 30,
                              child: Row(
                                children: <Widget>[
                                  Text('Doubts',style: GoogleFonts.montserrat(fontSize: 14),),
                                  SizedBox(width: 5,),
                                  Icon(Icons.book,size: 18,),
                                ],
                              ),
                            ),

                            SizedBox(width: 10,),

                            OutlineButton(
                              borderSide: BorderSide(color: Colors.red),
                              highlightedBorderColor: Colors.red,
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Confess()));
                              },
                              //height: 30,
                              child: Row(
                                children: <Widget>[
                                  Text('Confess',style: GoogleFonts.montserrat(fontSize: 14),),
                                  SizedBox(width: 5,),
                                  Icon(Icons.hearing,size: 18,),
                                ],
                              ),
                            ),

                            SizedBox(width: 10,),

                            OutlineButton(
                              borderSide: BorderSide(color: Colors.red),
                              highlightedBorderColor: Colors.red,
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UsersPage()));
                              },
                              //height: 30,
                              child: Row(
                                children: <Widget>[
                                  Text('Users',style: GoogleFonts.montserrat(fontSize: 14),),
                                  SizedBox(width: 5,),
                                  Icon(Icons.supervised_user_circle,size: 18,),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          height: 3,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(colors: [
                                Hexcolor('#E4181F'),
                                Hexcolor('#E5E5BE')
                              ]))),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        child: Text(
                          'Newsletter',
                          style: GoogleFonts.montserrat(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
