import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x3/home.dart';
import 'colors.dart';
import 'first_view.dart';
import 'reglog1.dart';
import 'provider_widget.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  var colors = CustomColors(WidgetsBinding.instance.window.platformBrightness);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      colors = CustomColors(WidgetsBinding.instance.window.platformBrightness);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      db: FirebaseFirestore.instance,
      colors: colors,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
        ),
        home: HomeController(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomeController(),
          '/signUp': (BuildContext context) => SignUpView(authFormType: AuthFormType.signUp),
          '/signIn': (BuildContext context) => SignUpView(authFormType: AuthFormType.signIn),
        },
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? HomePage() : FirstView();
        }
        return Container();
      },
    );
  }
}