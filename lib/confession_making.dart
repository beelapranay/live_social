import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class confessionMaking extends StatefulWidget {
  @override
  _confessionMakingState createState() => _confessionMakingState();
}

class _confessionMakingState extends State<confessionMaking> {

  TextEditingController titleController = TextEditingController();
  TextEditingController confessionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: AutoSizeText('Confess here',
                        style: GoogleFonts.anonymousPro(),minFontSize: 18,),
                    )
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title your confession',
                    labelStyle: GoogleFonts.anonymousPro(fontSize: 15,color: Colors.red),
                    border: InputBorder.none,
                  ),
                  cursorColor: Colors.red,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red,width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: confessionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Confess',
                      labelStyle: GoogleFonts.anonymousPro(fontSize: 15,color: Colors.red),
                      border: InputBorder.none,
                    ),
                    cursorColor: Colors.red,
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
