import 'dart:async';

import 'package:PlayAndLearn/pages/CategoryList.dart';
import 'package:PlayAndLearn/utilities/Constants.dart';
import 'package:PlayAndLearn/utilities/homemusic.dart';
// import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeMusic hm;

  HomeScreen(this.hm);
  HomeScreen.m();

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  HomeMusic hm = new HomeMusic();

  double devicewidth;
  double deviceheight;

  bool isPlaying = true;

  Icon _musicIcon;

  bool _isSelected = false;

  int minutes = 45;
  int curMin = 10;

  bool _isParentalSet = false;
  int totalMin = 45;

  String confirmText =
      "SAVE"; //TO take care of async saving of ParentalControls
  DateTime date = DateTime.now();
  DateTime saveddate;

  Timer timer;

  CategoryList _categoryList;

  final FlutterTts flutterTts = FlutterTts();

  //text on category
  String text = "";
  int currentindex = 0;

  bool isNewHomeMusic = false;

  void getCurrentCategoryText(String value) {
    text = value;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    checkParentalControl();

    _categoryList = new CategoryList();

    isNewHomeMusic = true;
    mediaPlayerInitial();
    arrowPressedInit();
    flutterTts.awaitSpeakCompletion(false);

    ttsInit();

    _musicIcon = Icon(Icons.volume_up_rounded);

    checkCurMin();
    timer = Timer.periodic(Duration(minutes: 1), (Timer t) => checkCurMin());
  } //end of init state

  @override
  void dispose() {
    hm.player.dispose();
    Constants.isTimerCreated = false;

    timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _musicIcon = Icon(Icons.volume_off_rounded);
        isPlaying = false;
        hm.player.pause();
        break;
      case AppLifecycleState.resumed:
        print("In Home Screen 2");
        if (!isPlaying) {
          _musicIcon = Icon(Icons.volume_up_rounded);
          isPlaying = true;

          hm.player.resume();
        }
        break;
      case AppLifecycleState.detached:
        _musicIcon = Icon(Icons.volume_off_rounded);
        isPlaying = false;

        print("In Home Screen 3");
        hm.player.pause();
        break;
      case AppLifecycleState.inactive:
        _musicIcon = Icon(Icons.volume_off_rounded);
        isPlaying = false;

        print("In Home Screen 4");
        hm.player.pause();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    devicewidth = MediaQuery.of(context).size.width;
    deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/background/cloud.gif'),
                fit: BoxFit.cover,
              )),
            ),
            Padding(
              padding: EdgeInsets.only(top: devicewidth * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.settings),
                              iconSize: 45.0,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    useSafeArea: true,
                                    builder: (context) {
                                      void result = checkParentalControl();
                                      return (_isParentalSet)
                                          ? _showErrorDialog()
                                          : _showDialog();
                                    });
                              },
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: deviceheight * 0.25,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_left),
                              iconSize: 45.0,
                              onPressed: () {
                                _categoryList.leftArrowClicked();
                                if (currentindex > 0) {
                                  currentindex--;
                                  _categoryList.finalClicked(currentindex);
                                } else {
                                  currentindex = Constants.categorycount - 1;
                                }
                                _categoryList.findValueAtIndex(
                                    this.getCurrentCategoryText, currentindex);
                                _speak();
                              },
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: deviceheight * 0.16,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            // child:AdmobBanner(
                            //   adSize: AdmobBannerSize.BANNER,
                            //   adUnitId: ams.getBannerAdId(),
                            // )
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: _categoryList,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 25.0),
                      child: Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: IconButton(
                                icon: _musicIcon,
                                iconSize: 45.0,
                                onPressed: () {
                                  musicInteraction();
                                },
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: deviceheight * 0.25,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_right),
                              iconSize: 45.0,
                              onPressed: () {
                                //hm.player.resume();

                                // hm.player.play("tunes/ArrowTap.mp3");
                                //hm.cache.load("tunes/tune1.mp3");
                                //hm.player2.play("ArrowTap.mp3");
                                _categoryList.rightArrowClicked();
                                if (currentindex <
                                    Constants.categorycount - 1) {
                                  currentindex++;
                                } else {
                                  currentindex = 0;
                                }
                                hm.cache2.load("tunes/ArrowTap.mp3");
                                //hm.player2.play("tunes/ArrowTap.mp3");
                                Future.delayed(Duration(seconds: 1));
                                _categoryList.findValueAtIndex(
                                    this.getCurrentCategoryText, currentindex);
                                _speak();

                                _categoryList.finalClicked(currentindex);
                              },
                              color: Colors.white,
                            ),
                          )
                        ],
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void musicInteraction() {
    if (isPlaying) {
      if (this.mounted) {
        setState(() {
          _musicIcon = Icon(Icons.volume_off_rounded);
          isPlaying = false;
          this.hm.player.pause();
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          _musicIcon = Icon(Icons.volume_up_rounded);
          isPlaying = true;
          this.hm.player.resume();
        });
      }
    }
  }

  Widget _showErrorDialog() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          backgroundColor: Colors.white,
          elevation: 6.0,
          insetAnimationCurve: Curves.easeIn,
          insetAnimationDuration: Duration(seconds: 2),
          child: Container(
              height: deviceheight * 0.7,
              width: devicewidth * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // border: Border.all(style: BorderStyle.none,width: 0.01),
                            ),
                            child: Icon(
                              Icons.error_outline_outlined,
                              size: 40.0,
                              color: Colors.pink,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Parental Controls",
                              style: TextStyle(
                                fontSize: 23.0,
                                fontFamily: 'Serif',
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ]),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 35.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's limit is already set.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Times New Roman',
                                wordSpacing: 0.0,
                              ))
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 36.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                            ),
                            child: Container(
                                height: deviceheight * 0.12,
                                width: devicewidth * 0.30,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  backgroundBlendMode: BlendMode.darken,
                                  gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.pink,
                                        Colors.purpleAccent,
                                      ]),
                                ),
                                child: FlatButton(
                                    onPressed: () {},
                                    child: FlatButton.icon(
                                        onPressed: () {
                                          //clearParentalControl();
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.close_rounded,
                                            color: Colors.white),
                                        label: Text(
                                          "CLOSE",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0),
                                        )))),
                          ),
                        ],
                      )),
                ],
              )),
        );
      },
    );
  }

  Widget _showDialog() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          backgroundColor: Colors.white,
          elevation: 6.0,
          insetAnimationCurve: Curves.easeIn,
          insetAnimationDuration: Duration(seconds: 2),
          child: Container(
              height: deviceheight * 0.7,
              width: devicewidth * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.assignment_ind_rounded,
                              size: 40.0,
                              color: Colors.pink,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Parental Controls",
                              style: TextStyle(
                                fontSize: 23.0,
                                fontFamily: 'Serif',
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ]),
                  ),
                  Padding(
                      padding: EdgeInsets.only(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text("Set app default (45 min) ",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Serif',
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          Switch(
                            value: _isSelected,
                            onChanged: (v) {
                              if (this.mounted) {
                                setState(() {
                                  _isSelected = v;
                                  //_isEnabled = v;
                                  if (!_isSelected) minutes = 45;
                                });
                              }
                            },
                            activeColor: Colors.pink,
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, left: 30.0),
                            child: Column(
                              children: [
                                Text("Minutes : ",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: 'Serif',
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                          Container(
                              height: deviceheight * 0.15,
                              width: devicewidth * 0.40,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                //border:Border.all(color:Colors.pink,width: 1.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: deviceheight * 0.5,
                                    width: deviceheight * 0.20,
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: FlatButton(
                                        child: Icon(
                                          Icons.remove_circle_outline_rounded,
                                          size: 40.0,
                                        ),
                                        onPressed: (_isSelected)
                                            ? null
                                            : () {
                                                if (this.mounted) {
                                                  setState(() {
                                                    if (curMin > 10)
                                                      curMin--;
                                                    else
                                                      curMin = 45;
                                                  });
                                                }
                                              }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0),
                                    child: Container(
                                      height: deviceheight * 0.5,
                                      width: deviceheight * 0.20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Text(
                                        (_isSelected)
                                            ? minutes.toString()
                                            : curMin.toString(),
                                        style: TextStyle(
                                            fontSize: 30.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: deviceheight * 0.5,
                                    width: deviceheight * 0.20,
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: FlatButton(
                                        child: Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 40.0,
                                        ),
                                        onPressed: (_isSelected)
                                            ? null
                                            : () {
                                                if (this.mounted) {
                                                  setState(() {
                                                    if (curMin < 45)
                                                      curMin++;
                                                    else
                                                      curMin = 10;
                                                  });
                                                }
                                              }),
                                  )
                                ],
                              )),
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                            ),
                            child: Container(
                                height: deviceheight * 0.12,
                                width: devicewidth * 0.30,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  backgroundBlendMode: BlendMode.darken,
                                  gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.pink,
                                        Colors.purpleAccent,
                                      ]),
                                ),
                                child: FlatButton(
                                    onPressed: () {},
                                    child: FlatButton.icon(
                                        onPressed: () {
                                          var temp = setParentalControl();
                                          if (this.mounted) {
                                            setState(() {
                                              confirmText = "SAVING ...";
                                            });
                                          }
                                          Future.delayed(Duration(seconds: 3),
                                              () {
                                            if (this.mounted) {
                                              setState(() {
                                                confirmText = "SAVE";
                                                Navigator.of(context).pop();
                                              });
                                            }
                                          });
                                        },
                                        icon: Icon(Icons.save_rounded,
                                            color: Colors.white),
                                        label: Text(
                                          "$confirmText",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0),
                                        )))),
                          ),
                        ],
                      )),
                ],
              )),
        );
      },
    );
  }

  void checkCurMin() async {
    print("IN check cur min");
    final prefs = await SharedPreferences.getInstance();
    int curmin = prefs.getInt('curmin') ?? -1;

    checkParentalControl();

    if (_isParentalSet) {
      if (curmin == -1) return;
      if (curmin == 1 || curmin == 0) {
        print("Time Over");
        curmin = 0;
        timer?.cancel();

        Navigator.of(context).pop();
        Navigator.pushNamed(context, '/timeover');
      } else {
        curmin -= 1;
        prefs.setInt('curmin', curmin);
      }
    }
  }

  //parentalminutes = totalMin , curmin = curMin , date = todays date , saveddate = date on parental control has been set
  void checkParentalControl() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('parentalminutes') ?? 0;
    final day = prefs.getInt('day') ?? 0;
    final month = prefs.getInt('month') ?? 0;
    final year = prefs.getInt('year') ?? 0;

    if (year == date.year && month == date.month && day == date.day) {
      if (this.mounted) {
        setState(() {
          _isParentalSet = true;
          totalMin = minutes;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          _isParentalSet = false;
        });
      }
    }
  }

  void setParentalControl() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('parentalminutes', curMin);
    prefs.setInt('curmin', curMin);
    prefs.setInt('day', date.day);
    prefs.setInt('month', date.month);
    prefs.setInt('year', date.year);

    if (this.mounted) {
      setState(() {
        _isParentalSet = true;
      });
    }
  }

  void clearParentalControl() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('parentalminutes');
    prefs.remove('curmin');

    if (this.mounted) {
      setState(() {
        _isParentalSet = false;
      });
    }
  }

  Future _speak() async {
    var result = await flutterTts.speak(text);
    //if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    //if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  void ttsInit() async {
    await flutterTts.setLanguage("en-US");

    await flutterTts.setSpeechRate(1.0);

    await flutterTts.setVolume(1.0);

    await flutterTts.setPitch(1.0);

    await flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
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

    //if (isNewHomeMusic) {
    this.hm.cache.loop(Constants.tunePath);
    setState(() {
      isPlaying = true;
    });
    //} else {
    //  this.hm.player.pause();
    //  this.hm.player.resume();
    //}
  }

  void arrowPressedInit() {
    hm.player2.durationHandler = (d) {
      if (this.mounted) {
        setState(() {
          hm.musiclength2 = d;
        });
      }
    };

    hm.player2.positionHandler = (pos) {
      if (this.mounted) {
        setState(() {
          hm.position2 = pos;
        });
      }
    };
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true), //exit(0)
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}

/*Navigator.pushReplacement(context,
new MaterialPageRoute(
builder: (context) => HomeScreen.m()))*/
