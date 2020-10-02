import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x3/confession_making.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class Confess extends StatefulWidget {
  @override
  _ConfessState createState() => _ConfessState();
}

class _ConfessState extends State<Confess> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: FloatingActionButton(
            child: Icon(Icons.mode_edit,color: Colors.white,),
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => confessionMaking()));
            },
          ),
        ),
//      appBar: AppBar(
//        centerTitle: true,
//        title: Text('Confess',style: GoogleFonts.montserrat(fontSize: 20,fontWeight: FontWeight.bold),),
//        backgroundColor: Colors.red,
//      ),
        body: StreamBuilder(
    stream:  FirebaseFirestore
        .instance
        .collection('Confessions')
        .orderBy('Timestamp',descending: true)
        .snapshots(),//postsStream(context).asBroadcastStream(),
    builder: (context, snapshot) {
    return snapshot.hasData ? ListView.builder(
    shrinkWrap: true,
    scrollDirection: Axis.vertical,
    itemCount: snapshot.data.documents.length,
    itemBuilder: (BuildContext context, int index) => posts(context, snapshot.data.documents[index])
    ) : Center(child: Container(child: CircularProgressIndicator(backgroundColor: Colors.white,valueColor: new AlwaysStoppedAnimation<Color>(Colors.red))));
    }
    ),
          ));
//        ),
//      ),
//    );
  }

  Widget posts(BuildContext context, DocumentSnapshot Order) {
    String url = Order.data()['url'];
    String title = Order.data()['title'];
    String confession = Order.data()['confession'];

    return new Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: title==null ? Container(height: 0,):Text(title,style: GoogleFonts.anonymousPro(fontSize: 20,fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  child: url==null?Container(height: 0,):AspectRatio(
                    aspectRatio: 10/9,
                    child: Container(
                      child:
                      //url==null ? Container(height: 0,):
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: NetworkImage(url),fit:BoxFit.cover
                          )
                        ),
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
                      child: confession==null ? null : ReadMoreText(
                        confession,style: GoogleFonts.anonymousPro(fontWeight: FontWeight.w300,fontSize: 16),
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
                  AutoSizeText('Posted: ${timeago.format(Order.data()['Timestamp'].toDate())}',style: GoogleFonts.anonymousPro(fontSize: 15),maxFontSize: 15,),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
