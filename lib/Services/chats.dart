import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x3/sharedpref.dart';
import 'package:project_x3/sharedprefvalues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'conversationscreen.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:project_x3/sharedprefvalues.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatRooms;
  String name = FirebaseAuth.instance.currentUser.displayName;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
            itemCount: snapshot.data.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ChatRoomsTile(
                userName: snapshot.data.documents[index].data()['chatRoomId']
                    .toString()
                    .replaceAll("_", "")
                    .replaceAll(name, ""),
                chatRoomId: snapshot.data.documents[index].data()["chatRoomId"],
              );
            })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  getUserChats(String itIsMyName) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }

  getUserInfogetChats() async {
    //Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    getUserChats(name).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${name}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
       centerTitle: true,
        title: Text('Chats',style: GoogleFonts.montserrat(fontSize: 20,fontWeight: FontWeight.bold),),
      ),
      body: Container(
        child: chatRoomsList(),
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  String url;

  getUrl() async {
    SharedPrefValues.url = await SharedPref.getUrl();
  }

  ChatRoomsTile({this.userName,@required this.chatRoomId});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ConversationScreen(
              chatRoomId: chatRoomId,
              name: userName,
            )
        ));
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 60,width: 60,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            border: Border.all(width: 2,color: Colors.red),
                            image: DecorationImage(image:AssetImage('assets/user.png') ,fit: BoxFit.cover)
                        ),
                      ),
                      SizedBox(width: 0,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: AutoSizeText(userName,style: GoogleFonts.montserrat(fontSize: 15),maxFontSize: 15,),
                      ),
                    ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}