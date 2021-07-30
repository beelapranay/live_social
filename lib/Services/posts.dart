import 'dart:io';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x3/upload.dart';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

TextStyle style = GoogleFonts.montserrat(fontSize: 18);
TextStyle styleb =GoogleFonts.montserrat(fontSize: 20,fontWeight: FontWeight.bold);
final String email = FirebaseAuth.instance.currentUser.email;


class _PostsState extends State<Posts> {

  bool load = true;
  bool isliked;
  Map likes;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        load = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
      return DefaultTabController(
          length: 2,
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context) => Upload()));},
              child: Icon(Icons.add,color: Colors.white,),
            ),
            appBar: AppBar(
              leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){Navigator.pop(context);},),
              backgroundColor: Colors.red,
              title: Text('BLOG',style: styleb),
              centerTitle: true,
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(child: Text('Posts',style: style)),
                  Tab(child: Text('My Posts',style: style))
                ],
              ),
            ),
            body: Center(
              child: load ? CircularProgressIndicator(
                backgroundColor: Colors.white,valueColor: new AlwaysStoppedAnimation<Color>(Colors.red))
                  : TabBarView(
                children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: StreamBuilder(
                          stream:  FirebaseFirestore
                              .instance
                              .collection('Posts')
                              .orderBy('Timestamp',descending: true)
                              .snapshots(),//postsStream(context).asBroadcastStream(),
                          builder: (context, snapshot) {
                            return snapshot.hasData ? ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (BuildContext context, int index) => posts(context, snapshot.data.docs[index])
                            ) : Center(child: Container(child: CircularProgressIndicator(backgroundColor: Colors.white,valueColor: new AlwaysStoppedAnimation<Color>(Colors.red))));
                          }
                      ),
                    ),

                  Container(
                    color: Colors.white,
                    child: StreamBuilder(
                        stream: FirebaseFirestore
                            .instance
                            .collection('UserPosts')
                            .doc(email)
                            .collection('Data').orderBy('Timestamp',descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return snapshot.hasData ?  ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (BuildContext context, int index) => userposts(context, snapshot.data.docs[index])
                          )
                          : Center(child: Container(child: CircularProgressIndicator(backgroundColor: Colors.white,valueColor: new AlwaysStoppedAnimation<Color>(Colors.red))));
                        }
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Stream<QuerySnapshot> userPostsStream(BuildContext context) async* {
    final String uid = FirebaseAuth.instance.currentUser.email;
    yield* FirebaseFirestore
        .instance
        .collection('UserPosts')
        .doc(uid)
        .collection('Data').orderBy('Timestamp',descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> postsStream(BuildContext context) async* {
    yield* FirebaseFirestore
        .instance
        .collection('Posts')
        .orderBy('Timestamp',descending: true)
        .snapshots();
  }



  Widget userposts(BuildContext context, DocumentSnapshot posts) {
    String url = posts.get('image');
    String caption = posts.get('Caption');

    return new Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  child: url == null
                      ? Container(
                    height: 0,
                  )
                      : AspectRatio(
                    aspectRatio: 10 / 9,
                    child: Container(
                      child:
                      //url==null ? Container(height: 0,):
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Column(children: <Widget>[
                  Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: caption==null ? null : ReadMoreText(
                          caption,style: GoogleFonts.poppins(fontWeight: FontWeight.w300,fontSize: 16),
                          trimLines: 2,
                          colorClickableText: Colors.white,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: '...Read more',
                          trimExpandedText: ' Read less...',
                        ),
                      ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      //border: Border.all(color: Colors.red,width: 2)
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text('Posted By: ${posts.get('Name')}',style: GoogleFonts.poppins(fontWeight: FontWeight.w300,fontSize: 15)),
                  SizedBox(width: 5,),
                  Text('Posted: ${timeago.format(posts.get('Timestamp').toDate())}',style: GoogleFonts.montserrat(fontSize: 15)),
                  SizedBox(height: 5,),
                  Text('E-Mail: ${posts.get('E-Mail')}',style: GoogleFonts.poppins(fontWeight: FontWeight.w400,fontSize: 15)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget posts(BuildContext context, DocumentSnapshot posts) {
    String url = posts.get('image');
    String caption = posts.get('Caption');
    String userUrl = posts.get('user');
    
    // Map likes = Order.data()['likes'];
    // int likecount = Order.data()['likecount'];

//    likePost(){
//      bool isLiked = likes[FirebaseAuth.instance.currentUser.uid] == true;
//
//      if(isLiked){
//        FirebaseFirestore.instance.collection('Posts')
//        .doc(pos)
//        setState(() {
//          likecount -= 1;
//          isliked = false;
//          likes[FirebaseAuth.instance.currentUser.uid] = false;
//        });
//      }
//    }

    return new Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Row(children: <Widget>[
              //   // Container(
              //   //   height: 60,width: 60,
              //   //     decoration: BoxDecoration(shape: BoxShape.circle,
              //   //       border: Border.all(width: 2,color: Colors.red),
              //   //         image: userUrl == null ? DecorationImage(image: AssetImage('assets/user.png'),fit: BoxFit.cover)
              //   //             : DecorationImage(image: NetworkImage(userUrl),
              //   //             fit: BoxFit.cover)
              //   //     ),
              //   // ),
              //   SizedBox(width: 10,),
              //   AutoSizeText('${posts.get('Name')}',style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),),
              // ]
              // ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  child: url == null
                      ? Container(
                    height: 0,
                  )
                      : AspectRatio(
                    aspectRatio: 10 / 9,
                    child: Container(
                      child:
                      //url==null ? Container(height: 0,):
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Column(children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: caption==null ? null : ReadMoreText(
                          caption,style: GoogleFonts.poppins(fontWeight: FontWeight.w300,fontSize: 16),
                        trimLines: 2,
                        colorClickableText: Colors.white,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: '...Read more',
                        trimExpandedText: ' Read less...',
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      //border: Border.all(color: Colors.red,width: 2)
                    ),
                  ),
                  SizedBox(height: 5,),
                  AutoSizeText('Posted By: ${posts.get('Name')}',style: GoogleFonts.montserrat(fontSize: 15),maxFontSize: 15,),
                  SizedBox(width: 5,),
                  AutoSizeText('Posted: ${timeago.format(posts.get('Timestamp').toDate())}',style: GoogleFonts.montserrat(fontSize: 15),maxFontSize: 15,),
                  SizedBox(height: 5,),
                  AutoSizeText('E-Mail: ${posts.get('E-Mail')}',style: GoogleFonts.montserrat(fontSize: 15),maxFontSize: 15,),
                  SizedBox(height: 5,),
                  // Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: Row(
                  //     children: <Widget>[
                  //       isliked==true ? IconButton(icon: Icon(Icons.favorite,color: Colors.red,), onPressed: (){
                  //         setState(() {
                  //           isliked = false;
                  //         });
                  //       }) : IconButton(icon: Icon(Icons.favorite_border,color: Colors.red), onPressed: (){
                  //         setState(() {
                  //           isliked = true;
                  //         });
                  //       }),
                  //       IconButton(icon: Icon(Icons.chat), onPressed: (){}),
                  //       IconButton(icon: Icon(Icons.send), onPressed: (){})
                  //     ],
                  //   )
                  // ),

                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
