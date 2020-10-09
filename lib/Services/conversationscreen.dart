import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String name;

  ConversationScreen({this.chatRoomId,this.name});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  Stream<QuerySnapshot> chats;
  String name = FirebaseAuth.instance.currentUser.displayName;
  TextEditingController messageEditingController = new TextEditingController();
  final _controller = ScrollController();



  Widget chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot){
        return snapshot.hasData ?  ListView.builder(
          controller: _controller,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              return MessageTile(
                message: snapshot.data.documents[index].data()["message"],
                sendByMe: name == snapshot.data.documents[index].data()["sendBy"],
              )
              ;
            }) : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name,
        "message": messageEditingController.text,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
      };

      //DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      FirebaseFirestore.instance.collection("chatRoom")
          .doc(widget.chatRoomId)
          .collection("chats")
          .add(chatMessageMap).catchError((e){
        print(e.toString());
      });
    }

      setState(() {
        messageEditingController.text = "";
      });
    }

  getChats(String chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  @override
  void initState() {
    getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.name,style: GoogleFonts.montserrat(fontSize: 20),),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(child: chatMessages(),height: MediaQuery.of(context).size.height*0.77,),
              //SizedBox(height: 50,),
              Container(
                //height: 70,
                padding: EdgeInsets.all(5),
//                decoration: BoxDecoration(
//                  border: Border.all(color: Colors.red)
//                ),
                alignment: Alignment.bottomCenter,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  //color: Color(0x54FFFFFF),
                  child: Row(
                    children: [
//                      Expanded(
//                          child:
                  SizedBox(
                    child: Container(
                              child: TextField(
                                onTap: (){
                                  Timer(
                                    Duration(seconds: 0),
                                        () => _controller.jumpTo(_controller.position.maxScrollExtent),
                                  );
                                },
                                controller: messageEditingController,
                                style: GoogleFonts.montserrat(),
                                cursorColor: Colors.red,
                                decoration: InputDecoration(
                                    hintText: "Message...",
                                    hintStyle: TextStyle(
                                      //color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            //)
                        ),
                    height: 50,
                    width: MediaQuery.of(context).size.width*0.7,
                  ),
                      SizedBox(width: 16,),
                      GestureDetector(
                        onTap: () {
                          addMessage();
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40)
                            ),
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.send)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  RegExp exp = new RegExp(r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
//  Iterable<Match> matches = exp.allMatches(message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
            top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomRight: Radius.circular(23)),
            color: sendByMe ? Colors.red : Colors.blueGrey,
        ),
        child: exp.hasMatch(message) ?
        GestureDetector(
          onTap: (){_launchURL(message);},
          child: Container(
            child: Text(message,
              style: GoogleFonts.montserrat(fontSize: 15,color: Colors.white,decoration: TextDecoration.underline),),
      ),
        ) : Text(message,
            textAlign: TextAlign.start,
            style: GoogleFonts.montserrat(fontSize: 15,color: Colors.white))
      ),
    );
  }

  _launchURL(message) async {
    if (await canLaunch(message)) {
      await launch(message);
    } else {
      throw 'Could not launch $message';
    }
  }

}

