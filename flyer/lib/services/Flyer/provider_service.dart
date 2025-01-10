
import 'package:flutter/material.dart';
import 'package:flyer/globals.dart' as globals;

class FlyerConnectionProvider extends ChangeNotifier{

  bool _isConnected = false;
  bool _PIDEnabled = false;

  bool _settingsChangeAllowed = true;
  bool _gbStart = true;

  bool _loggingEnabled = false;


  Map<String,String> _settings = new Map<String,String>();
  bool _settingsEmpty = true;

  String? _rtfValue;

  bool get isConnected => _isConnected;
  bool get PIDEnabled => _PIDEnabled;
  bool get settingsChangeAllowed => _settingsChangeAllowed;
  bool get isSettingsEmpty => _settingsEmpty;
  bool get hasGBStarted => _gbStart;
  bool get logEnabled => _loggingEnabled;

  String? get getRTF => _rtfValue;

  Map<String,String> get settings => _settings;

  void setConnection(bool c){

    _isConnected = c;
    globals.isConnected = c;
    notifyListeners();
  }


  void setPID(bool c){

    _PIDEnabled = c;
    notifyListeners();
  }

  void setSettingsChangeAllowed(bool c){

    _settingsChangeAllowed = c;
    notifyListeners();
  }

  void setSettings(Map<String,String> _s){

    _settings = _s;
    _settingsEmpty = false;

    notifyListeners();
  }

  void clearSettings(){
    _settings.clear();
    _settingsEmpty = true;

    notifyListeners();
  }

  void setGBStart(bool c){

    _gbStart = c;
    notifyListeners();
  }

  void setLogEnabled(bool c){
    _loggingEnabled = c;
    notifyListeners();
  }

  void setRTF(String? s){
    _rtfValue = s;
    notifyListeners();
  }
}
