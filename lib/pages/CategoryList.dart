import 'dart:io';

import 'package:PlayAndLearn/utilities/homemusic.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:PlayAndLearn/utilities/Constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class CategoryList extends StatefulWidget {
  _CategoryListState _categoryListState;

  @override
  _CategoryListState createState() {
    _categoryListState = _CategoryListState();
    return _categoryListState;
  }

  void rightArrowClicked() {
    _categoryListState.rightArrowClicked();
  }

  void leftArrowClicked() {
    _categoryListState.leftArrowClicked();
  }

  void finalClicked(int page) {
    _categoryListState.finalClicked(page);
  }

  void findValueAtIndex(Function getCurrentIndexValue, int index) {
    _categoryListState.findValueAtIndex(getCurrentIndexValue, index);
  }
}

class _CategoryListState extends State<CategoryList> {
  double devicewidth = 0.0;

  double deviceheight = 0.0;

  final DBRef = FirebaseDatabase.instance.reference();

  final CarouselController _carouselController = CarouselController();

  int passedindex;

  int categorycount = 0;

  Function getCurrentIndexValue;

  List<String> categoriesText = [];

  //String downloadUrl = "https://appsenjoy.com/TjkS7";
  String downloadUrl = "https://mega.nz/file/fQtnTQpC#C3ES0hobFm5lfuncB8jP23i1nEnDDAXOeGuFQ0j438w";
  String storeUrl = "/storage/emulated/0/Download";
  String contentType = "application/vnd.android.package-archive";
  //String fileName = "";
  String fileName = "Color_Hunt_Game.apk";

  _CategoryListState() {
    try {
      FlutterDownloader.initialize();
    } on Exception catch (e) {}
    getCategoryCount();

    final FlutterTts flutterTts = FlutterTts();
    final speakCompletion = flutterTts.awaitSpeakCompletion(true);
  }

  @override
  Widget build(BuildContext context) {
    devicewidth = MediaQuery.of(context).size.width;
    deviceheight = MediaQuery.of(context).size.height;

    //categoriesText = List.generate(categorycount, (index) => (String.fromCharCode(index+65)));
    return Center(
        child: Container(
      height: deviceheight * 0.69,
      width: devicewidth * 0.9,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.white,
          backgroundBlendMode: BlendMode.softLight),
      child: CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
          //height: 400,
          aspectRatio: 2.0,
          viewportFraction: 0.45,
          // initialPage: 0,
          //enableInfiniteScroll: true,
          reverse: false,
          //autoPlay: true,
          //autoPlayInterval: Duration(seconds: 3),
          //autoPlayAnimationDuration: Duration(milliseconds: 800),
          //autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
        items: categoriesText.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Padding(
                  padding: EdgeInsets.only(top: 40.0, bottom: 20.0, left: 0.0, right: 0.0),
                  child: Container(
                    alignment: Alignment.center,
                    width: devicewidth * 0.30,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        backgroundBlendMode: BlendMode.src,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2.0, spreadRadius: 1.0)]),
                    child: FutureBuilder(
                      future: getImage(i),
                      initialData: getInitialData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          //print("data = "+snapshot.data.toString());
                          return SafeArea(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (i.toLowerCase().compareTo("color hunt game") == 0) {
                                      var isLandRef = FirebaseStorage.instance.ref().child("Application/Color_Hunt_Game.apk");

                                      File localFile = new File(storeUrl + "/Color_Hunt_Game.apk"); //createTempFile();

                                      var status = await Permission.storage.status;
                                      if (status.isGranted) {
                                        isLandRef.writeToFile(localFile).then((snapshot) => {
                                              Scaffold.of(context).showSnackBar(new SnackBar(
                                                content: Text("Game has been downloaded. Install it from downloads."),
                                                padding: EdgeInsets.only(left: 10.0),
                                                behavior: SnackBarBehavior.floating,
                                                duration: Duration(seconds: 3),
                                                backgroundColor: Colors.blue[900],
                                              ))
                                            });
                                      } else if (status.isDenied) {
                                        await Permission.storage.request();
                                        Scaffold.of(context).showSnackBar(new SnackBar(
                                          content: Text("Try Again to Download"),
                                          padding: EdgeInsets.only(left: 10.0),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.blue[900],
                                        ));
                                      }
                                      else if(status.isPermanentlyDenied){
                                        await Permission.storage.request();
                                        Scaffold.of(context).showSnackBar(new SnackBar(
                                          content: Text("Try Again to Download"),
                                          padding: EdgeInsets.only(left: 10.0),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.blue[900],
                                        ));
                                      }
                                      else if(status.isUndetermined){
                                        await Permission.storage.request();
                                        Scaffold.of(context).showSnackBar(new SnackBar(
                                          content: Text("Try Again to Download"),
                                          padding: EdgeInsets.only(left: 10.0),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.blue[900],
                                        ));
                                      }
                                    } else {
                                      Navigator.of(context).pushReplacementNamed(Constants.workarea, arguments: {
                                        'category': i,
                                      });
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                          width: devicewidth * 0.20,
                                          child: FlatButton(
                                              height: deviceheight * 0.30,
                                              onPressed: () async {
                                                if (i.toLowerCase().compareTo("color hunt game") == 0) {
                                                  /*final taskId = await FlutterDownloader.enqueue(
                                                    fileName:fileName,
                                                    headers: {
                                                      "Content-Type": "$contentType",
                                                    },
                                                    url: downloadUrl,
                                                    savedDir: storeUrl,
                                                    showNotification: true, // show download progress in status bar (for Android)
                                                    openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                                                  );*/
                                                  var isLandRef = FirebaseStorage.instance.ref().child("Application/Color_Hunt_Game.apk");

                                                  File localFile = new File(storeUrl + "/Color_Hunt_Game.apk"); //createTempFile();

                                                  isLandRef.writeToFile(localFile).then((snapshot) => {
                                                        Scaffold.of(context).showSnackBar(new SnackBar(
                                                          content: Text("Game has been downloaded. Install it from downloads."),
                                                          padding: EdgeInsets.only(left: 10.0),
                                                          behavior: SnackBarBehavior.floating,
                                                          duration: Duration(seconds: 3),
                                                          backgroundColor: Colors.blue[900],
                                                        ))
                                                      });
                                                } else {
                                                  Navigator.of(context).pushReplacementNamed(Constants.workarea, arguments: {
                                                    'category': i,
                                                  });
                                                }
                                              },
                                              child: Image.network(snapshot.data))),
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        width: devicewidth * 0.20,
                                        child: Text(
                                          i,
                                          style: TextStyle(
                                              textBaseline: TextBaseline.ideographic,
                                              color: Colors.indigo,
                                              backgroundColor: Colors.white70,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                              letterSpacing: 2.0,
                                              fontFamily: 'Cursive',
                                              fontFamilyFallback: ['Times new Roman'],
                                              decorationColor: Colors.lime),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          //print(snapshot.error);
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ));
            },
          );
        }).toList(),
      ),
    ));
  }

  Future<dynamic> getImage(String image) async {
    final ref = FirebaseStorage.instance.ref().child('/Categories/' + image + '.jpg');
    // no need of the file extension, the name will do fine.
    var url = await ref.getDownloadURL();
    print("Data from : $url");
    return url;
  }

  void findValueAtIndex(Function getCurrentIndexValue, int index) {
    this.getCurrentIndexValue = getCurrentIndexValue;
    this.passedindex = index;

    String categorytext = categoriesText.elementAt(passedindex);
    getCurrentIndexValue(categorytext);
  }

  void rightArrowClicked() {
    _carouselController.nextPage();
  }

  void leftArrowClicked() {
    _carouselController.previousPage();
  }

  void finalClicked(int page) {
    _carouselController.animateToPage(page, curve: Curves.easeInOut, duration: Duration(seconds: 1));
  }

  void getCategoryCount() {
    DBRef.once().then((DataSnapshot data) {
      if (!mounted) return;
      setState(() {
        this.categorycount = int.parse(data.value['categorycount'].toString());
        Constants.categorycount = categorycount;
        //print("Data From Firebase = " + data.value['categorycount'].toString());
        for (int i = 1; i <= this.categorycount; i++) {
          //print(data.value['category'][i]['name'].toString());
          categoriesText.add(data.value['category'][i]['name'].toString());
        }
      });
    });
  }

  Future<int> getCategoryItemsCount(String category) async {
    var categoryRef = DBRef.child("category");
    int itemsCount = 0;

    await categoryRef.once().then((data) {
      for (int i = 1; i < data.value.length; i++) {
        var curObj = data.value[i];

        //print(data.value[i].toString());
        if (curObj['name'] == category) {
          itemsCount = int.parse(curObj['items'].toString());
          print("Items count from categoryList = " + itemsCount.toString());
          break;
        }
      }
    });
    Constants.itemsCategoryCount = itemsCount;
    print("Add to constant = " + Constants.itemsCategoryCount.toString());
    return itemsCount;
  }
}

String getInitialData() {
  return "https://icon-library.com/images/spinner-icon-gif/spinner-icon-gif-10.jpg";
}

/*
Transform(
alignment: Alignment.center,
transform: Matrix4.skewX(0.3),
child: child,
*/

//To download a file from URL
/*final taskId =
                                          await FlutterDownloader.enqueue(
                                        fileName: fileName,
                                        headers: {
                                          "Content-Type": "$contentType",
                                        },
                                        url: downloadUrl,
                                        savedDir: storeUrl,
                                        showNotification:
                                            true, // show download progress in status bar (for Android)
                                        openFileFromNotification:
                                            true, // click on notification to open downloaded file (for Android)
                                      );*/
