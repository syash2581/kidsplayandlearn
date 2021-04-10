import 'package:PlayAndLearn/pages/Welcome.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("On Message :  $message");
    }, onLaunch: (Map<String, dynamic> message) async {
      print("On Launch :  $message");
    }, onResume: (Map<String, dynamic> message) async {
      print("On Resume :  $message");
    });
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true,badge: true,alert: true));
  }

  @override
  Widget build(BuildContext context) {
    return Welcome();
  }
}
