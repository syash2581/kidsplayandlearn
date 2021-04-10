import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class Connection extends PropertyChangeNotifier<String> {
  static bool _isConnected = true;
  static bool _isAccessToInternet = true;
  var _connectivityResult;
  var connectivity = new Connectivity();

  StreamSubscription<ConnectivityResult> _connectionSubscription;



  Connection(){
    _connectionSubscription = connectivity.onConnectivityChanged.listen((event) {checkConnectivity();});
  }


  bool get isConnected => _isConnected;
  bool get isAccessToInternet => _isAccessToInternet;
  ConnectivityResult get connectivityResult => _connectivityResult;

  set isConnected(bool value) {
    _isConnected = value;
    notifyListeners('_isConnected');
  }

  set isAccessToInternet(bool value) {
    _isAccessToInternet = value;
    notifyListeners('_isAccessToInternet');
  }

  set connectivityResult(ConnectivityResult value) {
    _connectivityResult = value;
    notifyListeners('_connectivityResult');
  }

  Future<void> checkConnectivity() async  {
    _connectivityResult = (Connectivity().checkConnectivity());
    if (_connectivityResult == ConnectivityResult.none) {
      _isConnected = false;
      _isAccessToInternet = false;
    } else if (_connectivityResult == ConnectivityResult.mobile ||
        _connectivityResult == ConnectivityResult.wifi) {
      _isConnected = true;

      try {
        final result =await InternetAddress.lookup('https://www.google.com/');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _isAccessToInternet = true;
        }
      } on SocketException catch (_) {
        _isAccessToInternet = false;
      }
    }
  }
}
