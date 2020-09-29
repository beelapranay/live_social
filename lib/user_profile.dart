import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_x3/uploaddp.dart';
import 'package:uuid/uuid.dart';
import 'provider_widget.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({this.onSignedOut});
  final VoidCallback onSignedOut;
  @override
  _ProfileViewState createState() => _ProfileViewState();
}



class _ProfileViewState extends State<ProfileView> {
  File file;
  String postid = Uuid().v4();
  final StorageReference storageRef = FirebaseStorage.instance.ref();
  TextEditingController nedit = new TextEditingController();

  cameraPhoto() async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.camera,maxHeight: 675,maxWidth: 960);
    setState(() {
      this.file=file;
    });
  }

  galleryPhoto() async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file=file;
    });
  }

  Future updatePhotoURL(String url) async {
    await FirebaseAuth.instance.currentUser.updateProfile(photoURL: url);
    await FirebaseAuth.instance.currentUser.reload();
  }

  Future updateName(String name) async {
    await FirebaseAuth.instance.currentUser.updateProfile(displayName: name);
    await FirebaseAuth.instance.currentUser.reload();
  }

  select(context){
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return SimpleDialog(
            title: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.green),borderRadius: BorderRadius.circular(5)),
                child: Center(

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Upload Post',style: GoogleFonts.montserrat(fontSize: 20)
                      ),
                    )
                )
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Center(child: Text('Upload using Camera',style: GoogleFonts.montserrat(fontSize: 18))),
                onPressed: cameraPhoto,
              ),
              SimpleDialogOption(
                child: Center(child: Text('Upload using Gallery',style: GoogleFonts.montserrat(fontSize: 18))),
                onPressed: galleryPhoto,
              ),
              SimpleDialogOption(
                child: Center(child: Text('Cancel',style: GoogleFonts.montserrat(fontSize: 18,color: Colors.red))),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }


  //TextEditingController _userCountryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          centerTitle: true,
          title: Text('User Profile',style: GoogleFonts.montserrat(fontSize: 22,fontWeight: FontWeight.bold),),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);}),
        ),



        //backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: Provider.of(context).auth.getCurrentUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return displayUserInformation(context, snapshot);
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      );
  }

  Widget displayUserInformation(context, snapshot) {
    final authData = snapshot.data;
    final String url = FirebaseAuth.instance.currentUser.photoURL;


    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Name: ${authData.displayName ?? ''}",
            style: TextStyle(fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              child: url == null ? OutlineButton(child: Text('Upload DP'),onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context) => UploadDP()));})
              : Image.network(url)
          )
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Email: ${authData.email ?? ''}",
            style: TextStyle(fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Member from: ${DateFormat('dd/MM/yyyy').format(authData.metadata.creationTime).toString()}",
            style: TextStyle(fontSize: 20),
          ),
        ),
        RaisedButton(
          child: Text("Edit User"),
          onPressed: () {
            _userEditBottomSheet(context);
          },
        ),
      ],
    );
  }



  void _userEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * .60,
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text("Update Profile"),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.orange,
                      iconSize: 25,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: TextField(
                          controller: nedit,
                          decoration: InputDecoration(
                            helperText: "Name",
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Save'),
                      color: Colors.green,
                      textColor: Colors.white,
                      onPressed: () async {
                        updateName(nedit.text);
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}