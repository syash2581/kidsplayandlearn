import 'package:PlayAndLearn/pages/MessagingWidget.dart';
import 'package:PlayAndLearn/pages/WorkArea.dart';
import 'package:PlayAndLearn/utilities/Constants.dart';
import 'package:PlayAndLearn/utilities/homemusic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:PlayAndLearn/pages/TimeOver.dart';

//local classes
import 'package:PlayAndLearn/pages/Welcome.dart';
import 'package:PlayAndLearn/pages/HomeScreen.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIOverlays([]);
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Play and Learn',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.amber,
        accentColor: Colors.white,
      ),
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something Went Wrong");
          } else if (snapshot.hasData) {
            return MessagingWidget();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      routes: {
        //both is valid
        '${Constants.index}': (context) => Welcome(),
        Constants.home: (context) => HomeScreen(new HomeMusic()),
        Constants.timeover: (context) => TimeOver(),
        Constants.workarea : (context) => WorkArea(),
      },
    );
  }
}
