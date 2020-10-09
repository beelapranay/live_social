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

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  final ImagePicker _picker = ImagePicker();
  Map likes;
  int likecount;
  bool isloading = false;
  File file;
  String postid = Uuid().v4();
  final StorageReference storageRef = FirebaseStorage.instance.ref();
  TextEditingController captionc = new TextEditingController();
  final String dispname = FirebaseAuth.instance.currentUser.displayName;
  final String email = FirebaseAuth.instance.currentUser.email;

  cameraphoto() async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.camera,maxHeight: 675,maxWidth: 960);
    setState(() {
      this.file=file;
    });
  }

  galleryphoto() async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file=file;
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
                onPressed: cameraphoto,
              ),
              SimpleDialogOption(
                child: Center(child: Text('Upload using Gallery',style: GoogleFonts.montserrat(fontSize: 18))),
                onPressed: galleryphoto,
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
    String mediaurl = await upload(file);
    postintofirestore(mediaurl,captionc.text);
    captionc.clear();
    setState(() {
      file == null;
      isloading == false;
      postid = Uuid().v4();
    });
    Navigator.pop(context);
  }

  Future<String> upload(imageFile) async {
    StorageUploadTask uploadTask = storageRef.child("post_$postid.jpg").putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
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

  postintofirestore(String mediaurl, String caption){
//    FirebaseFirestore.instance
//        .collection('Posts').
//        doc(FirebaseAuth.instance.currentUser.uid).
//        collection('userPosts').
//        doc(postid).
//        set({
//      "postID": postid,
//      "userID": FirebaseAuth.instance.currentUser.uid,
//      "userName": dispname,
//      "image": mediaurl,
//      "caption": caption,
//      "timestamp": DateTime.now(),
//      "likes": likes
//    });
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postid)
        .set({
      'Name': dispname,
      'image' : mediaurl,
      'Caption': caption,
      'E-Mail': email,
      'user' : FirebaseAuth.instance.currentUser.photoURL,
      'Timestamp': DateTime.now()
    });

    FirebaseFirestore.instance
        .collection('UserPosts')
        .doc(email)
        .collection('Data')
        .add({
      'Name': 'You',
      'Caption': caption,
      'E-Mail': email,
      'user' : FirebaseAuth.instance.currentUser.photoURL,
      'Timestamp': DateTime.now(),
      'image': mediaurl,
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
              width: 250,
              child: TextFormField(
                cursorColor: Colors.red,
                controller: captionc,
                maxLines: null,
                style: GoogleFonts.montserrat(fontSize: 18,),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write a Caption...',
                  hintStyle: GoogleFonts.montserrat(fontSize: 18),
                  //labelStyle: GoogleFonts.montserrat(fontSize: 18,color: Colors.black)
                ),
              ),
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
