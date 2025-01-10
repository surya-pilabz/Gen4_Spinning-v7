import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/Carding/statusMessage.dart';
import 'package:flyer/screens/CardingScreens/running_carousel.dart';
import 'package:provider/provider.dart';

import '../../services/Carding/provider_service.dart';

class CardingStatusPageUI extends StatefulWidget {


  BluetoothConnection connection;
  Stream<Uint8List> statusStream;

  CardingStatusPageUI({required this.connection,required this.statusStream});

  @override
  _CardingStatusPageUIState createState() => _CardingStatusPageUIState();
}

class _CardingStatusPageUIState extends State<CardingStatusPageUI> {

  String _substate = "";

  String _errorSource = "";
  String _errorAction = "";
  String _errorInformation = "";
  String _errorCode = "";

  String _pauseReason = "";



  bool hasError = false;
  bool running = false;
  bool homing = false;
  bool pause = false;
  bool idle = false;

  int _coilerSensor=0;
  int _ductSensor=0;

  double _deliveryMtrsPerMin=0;


  late Stream<Uint8List> statusStream;
  late BluetoothConnection connection;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    statusStream = widget.statusStream;
    connection = widget.connection;
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    try{
      if (running || homing || pause || hasError) {
        //disable settings and diagnostic pages when running to prevent errors
        print("Running started");
        if (Provider.of<CardingConnectionProvider>(context, listen: false).settingsChangeAllowed) {
          Provider.of<CardingConnectionProvider>(context, listen: false).setSettingsChangeAllowed(false);
        }
      }
      else if(idle){
          try {
            Provider.of<CardingConnectionProvider>(context, listen: false).setSettingsChangeAllowed(true);
          }
          catch (e) {
            print("Status: ${e.toString()}");
          }

      }
    }
    catch(e){
      print("Status: Changing state error: ${e.toString()}");
    }

    if(connection.isConnected){

      try {
        return StreamBuilder<Uint8List>(
            stream: statusStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                String _d = utf8.decode(data!);
                print("\nStatus: data: " + _d);
                //print(snapshot.data);


                try {
                  Map<String, String> _statusResponse = StatusMessage().decode(_d);

                  if (!_statusResponse.isEmpty) {
                    _substate = _statusResponse["substate"]!;

                    switch (_substate) {
                      case "running":
                        hasError = false;
                        running = true;
                        homing = false;
                        pause = false;
                        idle = false;
                        break;
                      case "homing":
                        hasError = false;
                        running = false;
                        homing = true;
                        pause = false;
                        idle = false;
                        break;
                      case "error":
                        hasError = true;
                        running = false;
                        homing = false;
                        pause = false;
                        idle = false;
                        break;
                      case "pause":
                        hasError = false;
                        running = false;
                        homing = false;
                        pause = true;
                        idle = false;
                        break;
                      default:
                        hasError = false;
                        running = false;
                        homing = false;
                        pause = false;
                        idle = true;
                        break;
                    }

                    if (_statusResponse.containsKey("coilerSensor") && _statusResponse.containsKey("ductSensor")) {
                      

                      _coilerSensor = double.parse(_statusResponse["coilerSensor"]!).toInt();
                      _ductSensor = double.parse(_statusResponse["ductSensor"]!).toInt();
                    }

                    if (hasError) {
                      _errorInformation = _statusResponse["errorReason"]!;
                      _errorCode = _statusResponse["errorCode"]!;
                      _errorSource = _statusResponse["errorSource"]!;
                      _errorAction = "Action";
                    }
                    else if (running) {
                      _deliveryMtrsPerMin = double.parse(_statusResponse["deliveryMtrsPerMin"]!);
                    }
                    else if (pause) {
                      _pauseReason = _statusResponse["pauseReason"]!;
                    }
                  }
                }

                catch (e) {
                  print("status1: ${e.toString()}");
                }
              }

              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: _mainUI(),
              );
            }
        );
      }
      catch(e){
        return _placeHolder();
      }
    }
    else{
      return _checkConnection();
    }

  }


  Widget _mainUI(){
    //decides which ui should be used based on substate

    if(hasError){
      Provider.of<CardingConnectionProvider>(context, listen: false).setSettingsChangeAllowed(false);
      return _errorUI();
    }
    else if(running){
      Provider.of<CardingConnectionProvider>(context, listen: false).setSettingsChangeAllowed(false);
      return _runUI();
    }
    else if(homing){
      Provider.of<CardingConnectionProvider>(context, listen: false).setSettingsChangeAllowed(false);
      return _homingUI();
    }
    else if(pause){
      Provider.of<CardingConnectionProvider>(context, listen: false).setSettingsChangeAllowed(false);
      return _pauseUI();
    }
    else{
      //idle
      Provider.of<CardingConnectionProvider>(context, listen: false).setSettingsChangeAllowed(true);

      return _placeHolder();
    }
  }

  Widget _placeHolder(){
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.06,
                width: MediaQuery.of(context).size.width*0.9,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  _substate.toUpperCase()??"--",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _runUI(){

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _substate.toUpperCase(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery Speed",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _deliveryMtrsPerMin.toString(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        _sensorStatuses(_coilerSensor, _ductSensor),

        CardingRunningCarousel(connection: connection, multistream: statusStream),
      ],
    );
  }

  Widget _homingUI(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Container(
          padding: EdgeInsets.only(top: 10, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.06,
                width: MediaQuery.of(context).size.width*0.9,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  _substate.toUpperCase(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        _sensorStatuses(_coilerSensor, _ductSensor),

      ],
    );
  }

  Widget _pauseUI(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        SizedBox(
          height: 15,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _substate.toUpperCase(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height: 50,
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reason For Pause",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.08,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _pauseReason,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _errorUI(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        SizedBox(
          height: 15,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _substate.toUpperCase(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height: 50,
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Error Information",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                "$_errorInformation (${_errorCode})",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height: 50,
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Error Source",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _errorSource,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        /*
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Error Action",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.15,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _errorAction,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

         */


      ],
    );
  }

  Widget _sensorStatuses(int coilerStatus, int ductStatus){

    return Container(

      height: MediaQuery.of(context).size.height*0.20,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Coiler Sensor (${_coilerSensor==1? "On": "Off"})  ",
                style: TextStyle(fontSize: 18, color: Theme.of(context).highlightColor),
              ),
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(50),
                  color: coilerStatus==1? Colors.lightGreen: Colors.red
                ),
              ),

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Duct Sensor (${_ductSensor==1? "On": "Off"})  ",
                style: TextStyle(fontSize: 18, color: Theme.of(context).highlightColor),
              ),
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(50),
                    color: ductStatus==1? Colors.lightGreen: Colors.red
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _checkConnection(){

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Please Reconnect...", style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 15),),
          ],
        ),
      ),
    );
  }
}
