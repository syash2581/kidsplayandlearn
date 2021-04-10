import 'dart:async';

import 'package:PlayAndLearn/pages/CategoryList.dart';
import 'package:PlayAndLearn/pages/HomeScreen.dart';
import 'package:PlayAndLearn/utilities/Constants.dart';
import 'package:PlayAndLearn/utilities/homemusic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CategoryItems.dart';
import 'Fav.dart';

class WorkArea extends StatelessWidget {
  WorkArea() {
    print("In workarea constructor : ${Constants.isTimerCreated}");
    /*if (!Constants.isTimerCreated) {
      checkCurMin();
      timer = Timer.periodic(Duration(minutes: 1), (Timer t) => checkCurMin());
      Constants.isTimerCreated = true;
    } else {}*/

    checkCurMin();
    timer = Timer.periodic(Duration(minutes: 1), (Timer t) => checkCurMin());
  }

  var deviceHeight;
  var deviceWidth;

  var context;

  var unStarIcon = Icons.star_outline;
  var starIcon = Icons.star;
  var curStarIcon;

  Timer timer;
  DateTime date = DateTime.now();
  DateTime saveddate;

  int minutes = 45;
  int curMin = 10;

  bool _isParentalSet = false;
  int totalMin = 45;

  CategoryItems _categoryItem;
  int currentIndex = 0;
  String text = "";
  String category = "";

  static var isInFav = ValueNotifier<bool>(false);

  GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  var args;

  @override
  Widget build(BuildContext context) {
    curStarIcon = unStarIcon;
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    this.context = context;

    args = ModalRoute.of(context).settings.arguments;
    category = args['category'].toString();
    _categoryItem = new CategoryItems(category);

    return Scaffold(
      key: _globalKey,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white38,
              )
            ],
            borderRadius: BorderRadius.circular(5.0),
            shape: BoxShape.rectangle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, top: 15.0),
                    child: RaisedButton.icon(
                      color: Colors.blue[200],
                      shape: new CircleBorder(side: BorderSide.none),
                      padding: EdgeInsets.all(deviceHeight * 0.03),
                      onPressed: () {
                        _onWillPop();
                      },
                      icon: Padding(
                        padding: EdgeInsets.only(left: deviceHeight * 0.025),
                        child: Icon(
                          Icons.arrow_back,
                          size: 40.0,
                          color: Colors.black,
                        ),
                      ),
                      label: Text(""),
                      //height: deviceHeight * 0.18,
                    ),
                  ),
                  SizedBox(
                    width: deviceWidth * 0.615,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, top: 15.0),
                      child: this.category.toLowerCase() != "favorites"
                          ? RaisedButton.icon(
                              color: Colors.blue[200],
                              shape: new CircleBorder(side: BorderSide.none),
                              padding: EdgeInsets.all(deviceHeight * 0.03),
                              onPressed: () {
                                //_onWillPop(); Icons.star
                                //_categoryItem.changeStar(changeStar);
                                _categoryItem
                                    .changeData(currentIndex)
                                    .then((value) {
                                  isInFav.value = null;
                                  isInFav.value =
                                      _categoryItem.isInFavList(currentIndex);
                                  if (_categoryItem.isInFavList(currentIndex) ==
                                      false) {
                                    _displaySnackBar("added");
                                  } else {
                                    _displaySnackBar("removed");
                                  }
                                  /*Navigator.of(context).pushReplacementNamed(
                                      Constants.workarea,
                                      arguments: {
                                        'category': "Favorites"
                                      });*/
                                });

                                //_displaySnackBar("Modified");
                              },
                              icon: Padding(
                                padding:
                                    EdgeInsets.only(left: deviceHeight * 0.025),
                                child: ValueListenableBuilder(
                                  valueListenable: isInFav,
                                  builder: (context, value, child) {
                                    try {
                                      return Fav.getIcon(isInFav.value);
                                    } catch (e) {
                                      return Fav.getIcon(false);
                                    }
                                  },
                                ),
                                /*Fav.getIcon(true);*/
                                /*Fav.getIcon(_categoryItem.isInFavList(currentIndex)),*/ /* Icon(curStarIcon,size: 40.0,color: Colors.pink,),*/
                              ),
                              label: Text(""),
                              //height: deviceHeight * 0.18,
                            )
                          : Container(),
                    ),
                  ),
                ]),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton.icon(
                        color: Colors.blue[200],
                        shape: new CircleBorder(side: BorderSide.none),
                        padding: EdgeInsets.all(deviceHeight * 0.02),
                        onPressed: () {
                          _categoryItem.leftArrowClicked();
                          if (currentIndex > 0) {
                            currentIndex--;
                          } else {
                            currentIndex = Constants.itemsCategoryCount - 1;
                          }
                          _categoryItem.findValueAtIndex(
                              this.getCurrentCategoryText, currentIndex);
                          isInFav.value =
                              _categoryItem.isInFavList(currentIndex);
                          _categoryItem.speak(text);

                          _categoryItem.finalClicked(currentIndex);
                        },
                        icon: Icon(
                          Icons.skip_previous_sharp,
                          size: 52.0,
                        ),
                        label: Text(""),
                        //height: deviceHeight * 0.2,
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: deviceHeight * 0.65,
                        width: deviceWidth * 0.50,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 25.0,
                                  spreadRadius: 1.0)
                            ],
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(30.0),
                            color: Colors.white),
                        child: _categoryItem ??
                            Container(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            ),
                      ),
                      RaisedButton.icon(
                        color: Colors.blue[200],
                        shape: new CircleBorder(side: BorderSide.none),
                        padding: EdgeInsets.all(deviceHeight * 0.02),
                        onPressed: () {
                          _categoryItem.rightArrowClicked();
                          if (currentIndex < Constants.itemsCategoryCount - 1) {
                            currentIndex++;
                          } else {
                            currentIndex = 0;
                          }
                          _categoryItem.findValueAtIndex(
                              this.getCurrentCategoryText, currentIndex);
                          isInFav.value =
                              _categoryItem.isInFavList(currentIndex);
                          _categoryItem.speak(text);
                          _categoryItem.finalClicked(currentIndex);
                        },
                        icon: Icon(
                          Icons.skip_next_sharp,
                          size: 52.0,
                        ),
                        label: Text(""),
                        //height: deviceHeight * 0.2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getCurrentCategoryText(String value) {
    text = value;
  }

  Future<bool> _onWillPop() {
    this.timer.cancel();
    return Navigator.pushReplacement(
        context, new MaterialPageRoute(builder: (context) => HomeScreen.m()));
  }

  void _displaySnackBar(String ans) {
    _globalKey.currentState.showSnackBar(SnackBar(
      content: Text("Item is $ans to favourites. Check in Fav list"),
      padding: EdgeInsets.only(left: 10.0),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.blue[900],
      action: SnackBarAction(
        label: "Check",
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(Constants.workarea,
              arguments: {'category': "Favorites"});
        },
      ),
    ));
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

  void checkParentalControl() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('parentalminutes') ?? 0;
    final day = prefs.getInt('day') ?? 0;
    final month = prefs.getInt('month') ?? 0;
    final year = prefs.getInt('year') ?? 0;

    if (year == date.year && month == date.month && day == date.day) {
      _isParentalSet = true;
      totalMin = minutes;
    } else {
      _isParentalSet = false;
    }
  }
}
// GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemBuilder: (context,index)=> Text('$index'))
/*
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
          onPressed: () => Navigator.pushReplacement(context,
              new MaterialPageRoute(builder: (context) => HomeScreen.m())),
          child: new Text('Yes'),
        ),
      ],
    ),
  )) ?? false;
}*/
