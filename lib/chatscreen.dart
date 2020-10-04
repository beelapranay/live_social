import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  String name1;
  ChatScreen({Key key, this.name1}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController message = new TextEditingController();
  String mess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.name1,style: GoogleFonts.montserrat(fontSize: 20),),
        backgroundColor: Colors.red,
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Align(alignment: Alignment.bottomLeft,child: IconButton(icon: Icon(Icons.image,color: Colors.red,size: 35,), onPressed: (){})),
            //SizedBox(width: 10,),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width*0.6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2,color: Colors.red),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: TextFormField(
                    maxLines: null,
                    onSaved: (String value) {
                      mess = value;
                    },
                    controller: message,
                    style: GoogleFonts.montserrat(fontSize: 15),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Message...',
                      hintStyle: GoogleFonts.montserrat(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child:  IconButton(icon: Icon(Icons.send,color: Colors.red,size: 30,), onPressed: (){
                mess!=null ? print("sent") : null;
              }),
            )
          ],
        ),
      ),
    );
  }
}
