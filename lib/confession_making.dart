import 'dart:io';
import 'package:image/image.dart' as im;
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:readmore/readmore.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

class confessionMaking extends StatefulWidget {
  @override
  _confessionMakingState createState() => _confessionMakingState();
}

class _confessionMakingState extends State<confessionMaking> {

  TextEditingController titleController = TextEditingController();
  TextEditingController confessionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  File file;
  XFile xFile;
  List<XFile> imageFileList;
  set imageFile(XFile value) {
    imageFileList = value == null ? null : [value];
  }
  String postId = Uuid().v4();
  final storageRef = FirebaseStorage.instance.ref();
  TextEditingController captionC = new TextEditingController();
  final String displayName = FirebaseAuth.instance.currentUser.displayName;
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

  clear(){
    Navigator.pop(context);
    setState(() {
      file == null;
    });
  }

  Future<String> upload(imageFile) async {
    final uploadTask = storageRef.child("post_$postId.jpg").putFile(imageFile);
    final storageTaskSnapshot = await uploadTask.whenComplete(() => null);
    String url = await storageTaskSnapshot.ref.getDownloadURL();
    return url;
  }

  compress() async{
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    im.Image imagefile = im.decodeImage(file.readAsBytesSync());
    final compressedimage = File('$path/img_$postId.jpg')..writeAsBytesSync(im.encodeJpg(imagefile,quality: 80));
    setState(() {
      file = compressedimage;
    });
  }

  post() async{
    setState(() {
      isLoading = true;
    });
    if(file != null) {
      await compress();
      String mediaUrl = await upload(file);
      FirebaseFirestore.instance
          .collection('Confessions')
          .add({
        'title': titleController.text,
        'confession': confessionController.text,
        'Timestamp': DateTime.now(),
        'url': mediaUrl
      });
      setState(() {
        // ignore: unnecessary_statements
        file == null;
        // ignore: unnecessary_statements
        isLoading == false;
      });
      Navigator.pop(context);
    }
    else{
      FirebaseFirestore.instance
          .collection('Confessions')
          .add({
        'title': titleController.text,
        'confession': confessionController.text,
        'Timestamp': DateTime.now(),
        'url': "null"
      });
      Navigator.of(context).pop();
    }
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.red,
          title: Text("Confession Page",style: GoogleFonts.anonymousPro(fontSize: 20,color: Colors.white),),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
            setState(() {
              file==null;
            });
            Navigator.of(context).pop();
          }),
          actions: <Widget>[
            FlatButton(
              child: Text('Post',style: GoogleFonts.anonymousPro(fontSize: 20,color: Colors.white),),
              onPressed: isLoading ? null : post,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                isLoading ? LinearProgressIndicator(backgroundColor: Colors.red,) : Container(height: 0,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red,width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      style: GoogleFonts.anonymousPro(fontSize: 18),
                      maxLines: null,
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Wanna give a Title?',
                        hintStyle: GoogleFonts.anonymousPro(fontSize: 18,color: Colors.red.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.red,
                      //textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ),
                //SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red,width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      style: GoogleFonts.anonymousPro(fontSize: 18),
                      controller: confessionController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "What's your Confession?",
                        hintStyle: GoogleFonts.anonymousPro(fontSize: 18,color: Colors.red.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.red,
                      autocorrect: true,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                      child: file==null ? RaisedButton(
                          padding: EdgeInsets.all(10),
                          color: Colors.red,
                          onPressed: (){select(context);},
                          child: Text('Add Image',
                            style: GoogleFonts.anonymousPro(fontSize: 18,color: Colors.white),)
                      )
                        //Image.asset('assets/noim.png',fit: BoxFit.cover,),
                     : AspectRatio(
                        aspectRatio: 12/9,
                       child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(file)
                          )
                        ),
                    ),
                )
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: file==null ? Container(height: 0,):
                  RaisedButton(
                    padding: EdgeInsets.all(10),
                    color: Colors.red,
                    onPressed: (){select(context);},
                    child: Text('Take a new image',style: GoogleFonts.anonymousPro(fontSize: 18,color: Colors.white),),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }



}

