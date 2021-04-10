import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeOver extends StatefulWidget {
  @override
  _TimeOverState createState() => _TimeOverState();
}

class _TimeOverState extends State<TimeOver> {
  double devicewidth;
  double deviceheight;


  @override
  Widget build(BuildContext context) {
    devicewidth = MediaQuery.of(context).size.width;
    deviceheight = MediaQuery.of(context).size.height;
    return _showErrorDialog();
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
                          Text("Today's time is over.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Serif',
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
                                          SystemNavigator.pop();
                                        },
                                        icon: Icon(Icons.close_rounded,
                                            color: Colors.white),
                                        label: Text(
                                          "CLOSE APP",
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
}
