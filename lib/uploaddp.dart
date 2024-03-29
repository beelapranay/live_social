import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as im;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadDP extends StatefulWidget {
  @override
  _UploadDPState createState() => _UploadDPState();
}

class _UploadDPState extends State<UploadDP> {

  final ImagePicker _picker = ImagePicker();
  bool isloading = false;
  File file;
  String url;
  XFile xFile;
  List<XFile> imageFileList;
  set imageFile(XFile value) {
    imageFileList = value == null ? null : [value];
  }
  String postid = Uuid().v4();
  final storageRef = FirebaseStorage.instance.ref();
  TextEditingController captionc = new TextEditingController();
  final String dispname = FirebaseAuth.instance.currentUser.displayName;
  final String email = FirebaseAuth.instance.currentUser.email;

  cameraPhoto() async{
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      xFile = pickedFile;
      file = File(xFile.path);
    });
  }

  galleryPhoto() async{
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    setState(() {
      xFile = pickedFile;
      file = File(xFile.path);
    });
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

  Center splashScreen(){
    return Center(
      child: Container(
        color: Colors.white,//Theme.of(context).accentColor.withOpacity(0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: (){select(context);},
                child: Container(
                    child: Image.asset('assets/upload.jpg')
                )
            ),
          ],
        ),
      ),
    );
  }

  clear(){
    Navigator.pop(context);
    setState(() {
      file == null;
    });
  }

  post() async{
    setState(() {
      isloading = true;
    });
    await  compress();
    String mediaUrl = await upload(file);
    captionc.clear();
    updateUserImage(mediaUrl);
    FirebaseFirestore.instance
    .collection('Users')
    .doc(FirebaseAuth.instance.currentUser.uid)
    .update({'url': mediaUrl});
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({'user': mediaUrl});
    setState(() {
      // ignore: unnecessary_statements
      file == null;
      // ignore: unnecessary_statements
      isloading == false;
    });
    Navigator.pop(context);
  }

  Future updateUserImage(String url) async {
    await FirebaseAuth.instance.currentUser.updatePhotoURL(url);
    await FirebaseAuth.instance.currentUser.reload();
  }

  Future<String> upload(imageFile) async {
    final uploadTask = storageRef.child("post_$postid.jpg").putFile(imageFile);
    final storageTaskSnapshot = await uploadTask.whenComplete(() => null);

    String url = await storageTaskSnapshot.ref.getDownloadURL();
    return url;
  }

  compress() async{
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    im.Image imagefile = im.decodeImage(file.readAsBytesSync());
    final compressedimage = File('$path/img_$postid.jpg')..writeAsBytesSync(im.encodeJpg(imagefile,quality: 60));
    setState(() {
      file = compressedimage;
    });
  }

  Scaffold uploadscreen(){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Post',style: GoogleFonts.montserrat(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: clear),
        actions: <Widget>[
          FlatButton(
            child: Text('Post',style: GoogleFonts.montserrat(fontSize: 22,color: Colors.white),),
            onPressed: isloading ? null : post,
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isloading ? LinearProgressIndicator(
              backgroundColor: Colors.white,valueColor: new AlwaysStoppedAnimation<Color>(Colors.red)
          ) : Container(height: 0,),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
//                child: AspectRatio(
//                  aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(file)
                      )
                  ),
                ),
                //),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ListTile(
            //leading: CircleAvatar(backgroundColor: Colors.red,),
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.red),borderRadius: BorderRadius.circular(5)),
              width: 250
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file==null ? splashScreen() : uploadscreen();
  }
}
