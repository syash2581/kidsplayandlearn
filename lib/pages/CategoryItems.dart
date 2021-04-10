import 'package:PlayAndLearn/pages/WorkArea.dart';
import 'package:PlayAndLearn/utilities/Constants.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CategoryItems extends StatefulWidget {
  List<String> categoryItemsText;
  int categoryItemsCount = 0;
  String category = "";
  _CategoryItemsState _categoryItemsState;

  CategoryItems(String category) {
    this.category = category;
    //Constants.categorycount = categoryItemsCount;

    _categoryItemsState = new _CategoryItemsState(this.category);
    _categoryItemsState.getCategoryItems(this.category);
    _categoryItemsState.getFavCategoryItems();
  }

  @override
  _CategoryItemsState createState() {
    return _categoryItemsState;
  }

  void rightArrowClicked() {
    _categoryItemsState.rightArrowClicked();
  }

  void leftArrowClicked() {
    _categoryItemsState.leftArrowClicked();
  }

  void finalClicked(int page) {
    _categoryItemsState.finalClicked(page);
  }

  Future speak(String i) async {
    _categoryItemsState.speak(i);
  }

  void findValueAtIndex(Function getCurrentIndexValue, int index) {
    _categoryItemsState.findValueAtIndex(getCurrentIndexValue, index);
  }

  void changeStar(Function changeStar) {
    _categoryItemsState.changeStar(changeStar);
  }

  bool isInFavList(int index) {
    /* print(index.toString());
    if(index%2==0)
      return false;
    return true;*/
    return _categoryItemsState.isInFavList(index);
  }

  Future<bool> changeData(int index) async {
    return _categoryItemsState.changeData(index);
  }
}

class _CategoryItemsState extends State<CategoryItems> {
  List<String> spellingNotRequired = ["Alphabets", "Numbers"];
  List<String> categoryItemsText = [];
  List<String> favItemsText = [];
  int categoryItemsCount = 0;
  String category;
  bool fact = false;
  String data = "";

  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/Fav.txt');
  }

  var DBRef = FirebaseDatabase.instance.reference();

  _CategoryItemsState(String category) {
    final FlutterTts flutterTts = FlutterTts();

    this.category = category;
    getFavCategoryItems();
    getCategoryItems(this.category);

    //this.categoriesText = widget.categoryItemsText;
    //this.categoryItremsCount = widget.categoryItemsCount;
  }
  double deviceWidth = 0.0;

  double deviceHeight = 0.0;

  final CarouselController _carouselController = CarouselController();

  int passedIndex;

  Function getCurrentIndexValue;

  final FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    final speakCompletion = flutterTts.awaitSpeakCompletion(true);
    /*return ModelViewer(
      src: 'assets/icons/Untitled.glb',
      alt: "A 3D model of an astronaut",
      ar: true,
      autoRotate: true,
      cameraControls: true,
    );*/
    return Center(
        child: Container(
      height: deviceHeight * 0.6,
      width: deviceWidth * 0.68,
      child: CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
          //height: 400,
          aspectRatio: 2.0,
          viewportFraction: 1.0,
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
        items: this.categoryItemsText.map((i) {
          return Builder(
            builder: (BuildContext context) {
              /*return ModelViewer(
                src: 'assets/icons/Untitled.glb',
                alt: "A 3D model of an astronaut",
                ar: true,
                autoRotate: true,
                cameraControls: true,
              );*/

              return SafeArea(
                child: GestureDetector(
                  onLongPress: () {
                    print("Long pressed");
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: deviceWidth * 0.50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: FutureBuilder(
                      initialData: getInitialData(),
                      future: getImage(i),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          //print("data = " + snapshot.data.toString());
                          return Container(
                              width: deviceWidth * 0.5,
                              child: SafeArea(
                                child: Column(
                                  children: [
                                    FlatButton(
                                        padding: EdgeInsets.only(
                                            top: deviceHeight * 0.03),
                                        height: deviceHeight * 0.5,
                                        onPressed: () {
                                          speak(i);
                                        },
                                        child: Image.network(
                                          snapshot.data,
                                          height: spellingNotRequired
                                                  .contains(this.category)
                                              ? deviceHeight * 0.5
                                              : deviceHeight * 0.5,
                                          fit: BoxFit.cover,
                                        )),
                                    spellingNotRequired.contains(this.category)
                                        ? Text("")
                                        : Text(
                                            i,
                                            style: TextStyle(
                                                fontFamily: 'Cursive',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                                color: Colors.purpleAccent),
                                          ),
                                  ],
                                ),
                              ));
                        } else {
                          print(snapshot.error);
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    ));
  }

  Future<dynamic> getImage(String image) async {
    //print("in getImage = /${this.category}/' + $image + '.jpg'");
    final ref = FirebaseStorage.instance
        .ref()
        .child('/${this.category}/' + image + '.jpg');
    // no need of the file extension, the name will do fine.
    var url = await ref.getDownloadURL();
    return url;
  }

  String getInitialData() {
    return "https://icon-library.com/images/spinner-icon-gif/spinner-icon-gif-10.jpg";
  }

  void getCategoryItems(String category) {
    if (category != "Favorites") {
      var categoryRef = DBRef.child("categoryitems");
      //print("Category received = " + this.category);

      categoryRef.once().then((DataSnapshot data) {
        //print("Data from firebase = " + data.value.toString());

        var temp;
        for (int i = 1; i < data.value.length; i++) {
          temp = data.value[i];

          if (temp['categoryname'].toString().compareTo(this.category) == 0) {
            String item = temp['item'].toString();
            setState(() {
              categoryItemsText.add(item);
            });
          }
        }
        categoryItemsCount = categoryItemsText.length;
        Constants.itemsCategoryCount = categoryItemsCount;
      });
    } else {
      readData().then((value) {
        if (value != null) {
          setState(() {
            List<String> temp = value.split("\n").toList();
            for (String s in temp) {
              if (categoryItemsText.contains(s)) {
              } else {
                if (s != "\n" && s != " " && s.isNotEmpty)
                  categoryItemsText.add(s);
              }
            }
          });
          categoryItemsCount = categoryItemsText.length;
          Constants.itemsCategoryCount = categoryItemsCount;
          print(categoryItemsText);
        }
      });
    }
  }

  void findValueAtIndex(Function getCurrentIndexValue, int index) {
    this.getCurrentIndexValue = getCurrentIndexValue;
    this.passedIndex = index;

    String categoryText = categoryItemsText.elementAt(passedIndex);
    getCurrentIndexValue(categoryText);
  }

  void rightArrowClicked() {
    _carouselController.nextPage();
  }

  void leftArrowClicked() {
    _carouselController.previousPage();
  }

  void finalClicked(int page) {
    _carouselController.animateToPage(page,
        curve: Curves.easeInOut, duration: Duration(seconds: 1));
  }

  Future speak(String i) async {
    await flutterTts.speak(i);
    //var result = await flutterTts.speak(i);
    //if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  void changeStar(Function changeStar) {
    var temp;
    fact = !fact;
    if (fact)
      setState(() {
        temp = Icons.star;
      });
    else
      setState(() {
        temp = Icons.star_outline;
      });
    setState(() {
      changeStar(temp);
    });
  }

  bool isInFavList(int index) {
    getCategoryItems(this.category);
    getFavCategoryItems();
    WorkArea.isInFav.value =
        this.favItemsText.contains(this.categoryItemsText.elementAt(index));
    return WorkArea.isInFav.value;
  }

  void getFavCategoryItems() {
    /*writeData().then((value){
      print(value);
    });*/
    readData().then((value) {
      if (value != null) {
        List<String> temp = value.split("\n").toList();
        for (String s in temp) {
          if (favItemsText.contains(s)) {
          } else {
            favItemsText.add(s);
          }
        }
      }
    });
  }

  Future<bool> changeData(int index) async {
    String itemValue = categoryItemsText.elementAt(index);
    this.data = "";
    readData().then((value) {
      print("Value from file : " + value.toString());
      getFavCategoryItems();

      if (isInFavList(index)) {
        favItemsText.remove(itemValue);
        WorkArea.isInFav.value = false;
      } else {
        favItemsText.add(categoryItemsText.elementAt(index));
        WorkArea.isInFav.value = true;
      }

      for (String item in favItemsText) {
        print("Received Item : " + item);
        this.data = this.data + item + "\n";
      }
      writeData().then((value) {
        print("Written Data in string format : " + this.data);
        favItemsText.clear();
      });
    });
    return isInFavList(index);
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();

      return body;
    } catch (e) {}
  }

  Future<void> writeData() async {
    try {
      final file = await localFile;
      if (file.existsSync()) file.delete();
      file.writeAsString("$data");
      print("End of write function");
    } catch (e) {}
  }
}

/*
Transform(
alignment: Alignment.center,
transform: Matrix4.skewX(0.3),
child: child,
*/
