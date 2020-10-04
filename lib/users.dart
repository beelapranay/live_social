import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x3/chatscreen.dart';
import 'Services/posts.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text(
          'Users',
          style: styleb,
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(10),
        child: StreamBuilder(
            stream:  userDetailsStream(context),//postsStream(context).asBroadcastStream(),
            builder: (context, snapshot) {
              return snapshot.hasData ? ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) => users(context, snapshot.data.documents[index])
              ) : Center(child: Container(child: CircularProgressIndicator(backgroundColor: Colors.white,valueColor: new AlwaysStoppedAnimation<Color>(Colors.red))));
            }
        ),
      )
    );
  }

  Stream<QuerySnapshot> userDetailsStream(BuildContext context) async* {
    final String uid = FirebaseAuth.instance.currentUser.email;
    yield* FirebaseFirestore
        .instance
        .collection('Users')
        .orderBy('timestamp',descending: false)
        .snapshots();
  }

  Widget users(BuildContext context, DocumentSnapshot user) {
    String url = user.data()['image'];
    String caption = user.data()['Caption'];
    String userUrl = user.data()['url'];
    String name = user.data()['name'];
    String myname = FirebaseAuth.instance.currentUser.displayName;
    String docname = name+'_'+myname;

    return new Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 60,width: 60,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          border: Border.all(width: 2,color: Colors.red),
                          image: userUrl == null ? DecorationImage(image: AssetImage('assets/user.png'),fit: BoxFit.cover)
                              : DecorationImage(image: NetworkImage(userUrl),
                              fit: BoxFit.cover)
                      ),
                    ),
                    SizedBox(width: 0,),
                    AutoSizeText(name,style: GoogleFonts.montserrat(fontSize: 15),maxFontSize: 15,),
                    SizedBox(width: 100),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlineButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  ChatScreen(name1: name,)));
                          FirebaseFirestore.instance.collection('chats')
                          .doc(docname).set({
                            'created': DateTime.now()
                          });
                        },
                        borderSide: BorderSide(color: Colors.red),
                        highlightedBorderColor: Colors.red,
                        child: Text('Listen',style: GoogleFonts.montserrat(color: Colors.red),),
                      ),
                    ),
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }

}

