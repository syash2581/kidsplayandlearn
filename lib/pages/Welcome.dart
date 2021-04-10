import 'dart:async';
import 'dart:io';

import 'package:PlayAndLearn/pages/HomeScreen.dart';
import 'package:PlayAndLearn/utilities/Constants.dart';
import 'package:PlayAndLearn/utilities/homemusic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  HomeMusic hm = HomeMusic();
  //AnimationController controller;
  double devicewidth = 0.0;
  double deviceheight = 0.0;

  double textFontSize = 0.1;
  bool flag = true;

  var connectivityResult;
  bool isConnected = false;
  bool isAccessToInternet = false;

  String message = "OK";

  var _connectivityResult;
  var connectivity = new Connectivity();

  var t;

  @override
  void initState() {
    super.initState();
    checkConnectivity();

    WidgetsBinding.instance.addObserver(this);
    mediaPlayerInitial();

    t = new Timer.periodic(const Duration(seconds: 2), animateWelcomeText);

    // animatedPageRoute();
    askPermission();
    hm.cache.loop(Constants.tunePath);
  }

  Future<void> askPermission() async {
    PermissionStatus status = await Permission.storage.request();

    if(status.isDenied || status.isPermanentlyDenied){
      askPermission();
    }
    else if(status.isGranted)
      {
        animatedPageRoute();
      }
    // var status = await Permission.storage.status;
    // var status2 = await Permission.camera.status;
  }

  /*@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print("In welcome 1");
        hm.player.pause();
        break;
      case AppLifecycleState.resumed:
        print("In welcome 2");
        hm.player.resume();
        break;
      case AppLifecycleState.detached:
        print("In welcome 3");
        hm.player.pause();
        break;
      case AppLifecycleState.inactive:
        print("In welcome 4");
        hm.player.pause();
        break;
    }
  }*/

  @override
  void dispose() {
    t.cancel();
    this.hm.player.dispose();
    //_connectionSubscription.cancel();
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    devicewidth = MediaQuery.of(context).size.width;
    deviceheight = MediaQuery.of(context).size.height;

    if (isConnected && isAccessToInternet) {
      return Scaffold(
          body: Center(
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.blue[400],
                image: DecorationImage(
                  image: AssetImage('assets/welcomeimages/welcome.png'),
                  fit: BoxFit.cover,
                ),
                backgroundBlendMode: BlendMode.darken),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 00.0, 00.0, 0.0),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: AnimatedCrossFade(
                  duration: Duration(seconds: 1),
                  reverseDuration: Duration(seconds: 1),
                  firstCurve: Curves.fastOutSlowIn,
                  secondCurve: Curves.fastOutSlowIn,
                  alignment: Alignment.bottomRight,
                  firstChild: getPositionedText("Play", Alignment.bottomLeft, Colors.orange),
                  secondChild: getPositionedText("&Learn", Alignment.bottomRight, Colors.orange),
                  crossFadeState: flag ? CrossFadeState.showSecond : CrossFadeState.showFirst),
            ),
          )
        ]),
      ));
    } else {
      return Scaffold(
        body: Center(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.blue[400],
                    image: DecorationImage(
                      image: AssetImage('assets/welcomeimages/welcome.png'),
                      fit: BoxFit.cover,
                    ),
                    backgroundBlendMode: BlendMode.darken),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: deviceheight * 0.8,
                  width: devicewidth * 0.6,
                  child: AlertDialog(
                    title: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // border: Border.all(style: BorderStyle.none,width: 0.01),
                      ),
                      child: Icon(
                        Icons.error_outline_outlined,
                        size: 53.0,
                        color: Colors.pink,
                      ),
                    ),
                    titlePadding: EdgeInsets.only(left: 5.0, top: 10.0, right: 0.0, bottom: 0.0),
                    content: Container(
                        decoration: BoxDecoration(
                            //gradient: LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors:[Colors.red,Colors.lightBlueAccent],tileMode: TileMode.mirror)
                            ),
                        child: isConnected && !isAccessToInternet
                            ? Text("Waiting For Internet Access", textAlign: TextAlign.center)
                            : Text("Turn on WI-FI or Mobile Data & Restart The App", textAlign: TextAlign.center)),
                    contentTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      // s
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                      wordSpacing: 0.0,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(bottom: deviceheight * 0.05),
                        child: Container(
                            height: deviceheight * 0.1,
                            width: devicewidth * 0.8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              backgroundBlendMode: BlendMode.darken,
                              gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
                                Colors.pink,
                                Colors.purpleAccent,
                              ]),
                            ),
                            child: FlatButton(
                                onPressed: () {},
                                child: FlatButton(
                                    onPressed: () => SystemNavigator.pop(),
                                    child: Text(
                                      "OK",
                                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                                    )))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> checkConnectivity() async {
    // print("Check Conctivity Called");

    _connectivityResult = await (Connectivity().checkConnectivity());
    if (_connectivityResult == ConnectivityResult.none) {
      if (this.mounted) {
        setState(() {
          isConnected = false;
          isAccessToInternet = false;
        });
      }
    } else if (_connectivityResult == ConnectivityResult.mobile || _connectivityResult == ConnectivityResult.wifi) {
      var temp = true;

      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (this.mounted) {
            setState(() {
              isConnected = temp;
              isAccessToInternet = true;
            });
          }
        }
      } on SocketException catch (_) {
        if (this.mounted) {
          setState(() {
            isConnected = temp;
            isAccessToInternet = false;
          });
        }
      }
    }
  }

  // void connectivityChanged(){
  //   print("Properties Changed");
  //   con.checkConnectivity();
  //   setState(() {
  //     isConnected = con.isConnected;
  //     isAccessToInternet = con.isAccessToInternet;
  //     message = "Turned On";
  //   });
  // }

  Widget getPositionedText(String text, Alignment align, Color _color) {
    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(50.0, 0.0, 10.0, 5.0),
        child: Text(
          "$text",
          style: TextStyle(
              color: _color,
              fontSize: deviceheight * textFontSize,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontFamily: 'Times new roman'),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }

  void mediaPlayerInitial() {
    hm.player.durationHandler = (d) {
      if (this.mounted) {
        setState(() {
          hm.musiclength = d;
        });
      }
    };

    hm.player.positionHandler = (pos) {
      if (this.mounted) {
        setState(() {
          hm.position = pos;
        });
      }
    };
    hm.cache.load(Constants.tunePath);
  }

  void animateWelcomeText(Timer t) async {
    if (this.mounted) {
      setState(() {
        if (flag) {
          flag = false;
        } else {
          flag = true;
        }
      });
    }
  }

  void animatedPageRoute() {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              transitionDuration: Duration(seconds: 1),
              transitionsBuilder: (context, Animation<double> animation, Animation<double> secanimation, Widget widget) {
                animation = CurvedAnimation(parent: animation, curve: Curves.elasticOut);

                return ScaleTransition(
                  scale: animation,
                  child: widget,
                  alignment: Alignment.center,
                );
              },
              pageBuilder: (context, Animation<double> animation, Animation<double> secanimation) {
                if (isConnected && isAccessToInternet) {
                  return HomeScreen(hm);
                } else {
                  return SafeArea(
                    child: Center(
                        child: Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue))],
                          ),
                          SizedBox(
                            height: deviceheight * 0.2,
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              "Internet Access is not available.\nTurn on mobile data or wifi and restart the app.",
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            )
                          ]),
                        ],
                      ),
                    )
                        //child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),),
                        ),
                  );
                }
              }));
    });

    /*
      Navigator.of(context).pop();
        Navigator.push(
            context,
                });*/
  }
}
