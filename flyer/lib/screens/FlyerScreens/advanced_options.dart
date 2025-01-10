import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/Flyer/enums.dart';
import 'package:flyer/message/gearBoxMessage.dart';
import 'package:flyer/message/logging_message.dart';
import 'package:flyer/message/Flyer/rtf_message.dart';

import 'package:flyer/services/snackbar_service.dart';
import 'package:provider/provider.dart';
import '../../services/Flyer/provider_service.dart';
import 'package:flyer/message/Flyer/settingsMessage.dart';

class FlyerAdvancedOptionsUI extends StatefulWidget {

  BluetoothConnection connection;
  Stream<Uint8List> stream;

  FlyerAdvancedOptionsUI({required this.connection, required this.stream});

  @override
  _FlyerAdvancedOptionsUIState createState() => _FlyerAdvancedOptionsUIState();
}

class _FlyerAdvancedOptionsUIState extends State<FlyerAdvancedOptionsUI> {


  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  late BluetoothConnection connection;
  late Stream<Uint8List> stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    connection = widget.connection;
    stream = widget.stream;

    try{
      stream!.listen(_onDataReceived).onDone(() {});
    }
    catch(e){

      print("enabled: Listening init: ${e.toString()}");
    }

  }

  @override
  void dispose() {
    // TODO: implement dispose

    _data.clear;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 3, bottom: 7,),
              child: Center(
                child: Text(
                  "Advanced Options",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),

            SwitchListTile(
              title: const Text('Enable Logging', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 18),),
              value: Provider.of<FlyerConnectionProvider>(context,listen: false).logEnabled,
              contentPadding: EdgeInsets.only(top: 10,left: 18, right: 10, bottom: 10),
              onChanged: (bool value) async {

                try{

                  String _m;
                  String _msg;

                  if(value){
                    _m = LogMessage().enableLog();
                    _msg = "Enabled";
                  }
                  else{
                    _m = LogMessage().disableLog();
                    _msg = "Disabled";
                  }


                  connection!.output.add(Uint8List.fromList(utf8.encode(_m)));
                  await connection!.output!.allSent;

                  await Future.delayed(Duration(milliseconds: 200));

                  if(newDataReceived){

                    newDataReceived = false;
                    String _d = _data.last;

                    if(_d==null || _d==""){

                      SnackBar _sb = SnackBarService(message: "Invalid Packet", color: Colors.red).snackBar();
                      ScaffoldMessenger.of(context).showSnackBar(_sb);


                      throw FormatException("enable: Invalid Packet");

                    }

                    else if(_d==Acknowledgement().createPacket()){

                      Provider.of<FlyerConnectionProvider>(context,listen: false).setLogEnabled(value);

                      SnackBar _sb = SnackBarService(message: "Logging ${_msg}", color: Colors.green).snackBar();
                      ScaffoldMessenger.of(context).showSnackBar(_sb);


                    }
                    else{
                      SnackBar _sb = SnackBarService(message: "Error in Logging", color: Colors.red).snackBar();
                      ScaffoldMessenger.of(context).showSnackBar(_sb);

                      print("log: Failed");

                      throw FormatException("log Failed");

                    }

                  }


                  setState(() {

                  });

                }
                catch(e){

                  print("adv op: enable : ${e.toString()}");
                }

              },
              activeColor: Colors.lightGreen,
              inactiveThumbColor: Colors.blue,
            ),
            const Divider(
              color: Colors.grey,
            ),
            FlyerMotorGearPageUI(connection: widget.connection, stream: widget.stream),
            const Divider(
              color: Colors.grey,

            ),

            Container(
              padding: EdgeInsets.only(left: 10,top: 10,bottom: 5),
              margin: EdgeInsets.only(left: 10),
              child: const Text('RTF Settings', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 18),),
            ),
            FlyerRTFUI(connection: widget.connection, stream: widget.stream),
          ],
        ),
    );
  }

  void _onDataReceived(Uint8List data) {

    try {
      String _d = utf8.decode(data);

      if(_d==null || _d==""){
        throw FormatException('Invalid Packet');
      }

      if(_d == Acknowledgement().createPacket() || _d == Acknowledgement().createPacket(error: true)){

        //Allow if:
        //request settins data
        // or if acknowledgement (error or no error )

        _data.add(_d);
        newDataReceived = true;
      }

      //else ignore data

    }
    catch (e){

      print("rtf : onDataReceived: ${e.toString()}");
    }
  }
}



class FlyerMotorGearPageUI extends StatefulWidget {

  BluetoothConnection connection;
  Stream<Uint8List> stream;

  FlyerMotorGearPageUI({required this.connection, required this.stream});

  @override
  _FlyerMotorGearPageUIState createState() => _FlyerMotorGearPageUIState();
}

class _FlyerMotorGearPageUIState extends State<FlyerMotorGearPageUI> {

  bool start = true;
  bool stop = false;
  bool left = false;
  bool right = false;

  late bool firstTimeFlag;

  String? leftData, rightData;



  Map<String,String> _ldata = new Map<String,String>();

  Map<String,String> _rdata = new Map<String,String>();

  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  late BluetoothConnection connection;
  late Stream<Uint8List> stream;


  @override
  void initState() {
    // TODO: implement initState

    firstTimeFlag = true;

    connection = widget.connection;
    stream = widget.stream;


    try{
      stream!.listen(_onDataReceived).onDone(() {});
    }
    catch(e){

      print("Settings: Listening init: ${e.toString()}");
    }

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _data.clear();
    _rdata.clear();
    _ldata.clear();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    start = (Provider.of<FlyerConnectionProvider>(context,listen: false).settingsChangeAllowed && Provider.of<FlyerConnectionProvider>(context,listen: false).hasGBStarted);

    print("$start");

    if(start && firstTimeFlag){

      stop = false;
      left = false;
      right = false;

      firstTimeFlag = false;
    }
    else if(start && !firstTimeFlag){

      stop = false;
      left = true;
      right = true;
      firstTimeFlag = false;
    }
    else{

      left = false;
      right = false;
      stop = true;
      firstTimeFlag = false;
    }


    try{
      return Container(
        height: MediaQuery.of(context).size.height*0.4,
        width: MediaQuery.of(context).size.width,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
              padding: EdgeInsets.all(7),
              margin: EdgeInsets.only(top: 8, left: 7),
              child: Text(
                "Gear Box Settings",
                style:  TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ),

            SizedBox(height: 15),

            _leftAndRight(),

            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                Provider.of<FlyerConnectionProvider>(context,listen: false).settingsChangeAllowed? _customButton("START", start, _start): Container(),
                Provider.of<FlyerConnectionProvider>(context,listen: false).settingsChangeAllowed? _customButton("STOP", stop, _stop): Container(),
              ],
            ),
          ],
        ),
      );
    }
    catch(e){

      print("GB: BUILD: ${e.toString()}");
      return Container(

          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,

          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Container(
                    height: MediaQuery.of(context).size.height*0.05,

                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      "Gear Box Calibration",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ]
          ),
      );
    }
  }

  Widget _customRow(String label, String val, bool enabled,VoidCallback function){

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Container(

          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(left: 5),

          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        Container(

          height: MediaQuery.of(context).size.height*0.05,
          width: MediaQuery.of(context).size.width*0.4,
          padding: EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),

          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),

          child: Text(
            val,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      ],
    );

  }

  Widget _customButton(String label, bool enabled, VoidCallback function){

    if(enabled){
      return Container(
        height: MediaQuery.of(context).size.height*0.05,
        width: MediaQuery.of(context).size.width*0.40,
        margin: EdgeInsets.only(top: 40),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.blue,Colors.lightGreen]
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              function();
            },
            child: Text(label,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),

          ),
        ),
      );
    }
    else{
      return Container(
        height: MediaQuery.of(context).size.height*0.05,
        width: MediaQuery.of(context).size.width*0.40,
        margin: EdgeInsets.only(top: 40),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey,
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: (){
              print("gb: btns: disabled");
            },
            child: Text(label,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),

          ),
        ),
      );
    }
  }


  Widget _leftAndRight(){

    if(start==true){
      //start state not enabled

      print(_ldata.length);
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          _customRow("Left ", _ldata.isEmpty? leftData??"-":_ldata["data"]??"-", left, _sendLeft),

          SizedBox(height: 20,),
          _customRow("Right", _rdata.isEmpty? rightData??"-": _rdata["data"]??"-", right, _sendRight),
        ],
      );
    }
    else{

      return StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {


            if(snapshot.hasData){

              var data = snapshot.data;
              String _d = utf8.decode(data!);
              print("\nStatus: data: "+_d);
              print(snapshot.data);

              try{
                var _gbStatus = GearBoxMessage().decode(_d);


                leftData = _gbStatus["start"];
                rightData = _gbStatus["stop"];

                if(leftData!=null){
                  _ldata["data"] = leftData!;
                  _ldata["data"] = leftData!;
                }

                if(rightData!=null){
                  _rdata["data"] = rightData!;
                }

              }
              catch(e){
                print("GB: L&R: ${e.toString()}");
              }

            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                _customRow("Left ", leftData??"-", left, _sendLeft),

                SizedBox(height: 20,),
                _customRow("Right", rightData??"-", right, _sendRight),
              ],
            );
          }
      );
    }
  }


  void _sendLeft() async {


    try {
      connection!.output.add(Uint8List.fromList(utf8.encode(GearBoxMessage().left())));
      await connection!.output!.allSent;

      await Future.delayed(Duration(milliseconds: 500));

      if(newDataReceived){

        newDataReceived = false;
        String _d = _data.last;

        if (_d == null || _d == "") {
          SnackBar _sb = SnackBarService(
              message: "Invalid Packet", color: Colors.red).snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);

          print("GB: Send LEFT: Invalid Packet");

          throw FormatException("GB: Send LEFT: Invalid Packet");
        }

        if (_d == Acknowledgement().createPacket()) {
          SnackBar _sb = SnackBarService(
              message: "Saved Left Data", color: Colors.green).snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);
        }
        else {
          SnackBar _sb = SnackBarService(
              message: "Failed To Save Left Data", color: Colors.red)
              .snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);

          print("GB: Send Left: Failed");

          throw FormatException("GB: Send Left: Failed");
        }
      }
    }
    catch(e){

      SnackBar _sb = SnackBarService(message: "Failed To Save Left Data", color: Colors.red).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);

      print("GB: SEND LEFT ${e.toString()}");
    }


  }

  void _sendRight() async {

    try {
      connection!.output.add(Uint8List.fromList(utf8.encode(GearBoxMessage().right())));
      await connection!.output!.allSent;

      await Future.delayed(Duration(milliseconds: 500));



        if(newDataReceived){

          String _d = _data.last;

          if(_d==null || _d==""){

            SnackBar _sb = SnackBarService(message: "Invalid Packet", color: Colors.red).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);

            print("GB: Send Right: Invalid Packet");

            throw FormatException("GB: Send right: Invalid Packet");

          }

          else if(_d==Acknowledgement().createPacket()){
            SnackBar _sb = SnackBarService(message: "Saved Right Data", color: Colors.green).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);
          }
          else{
            SnackBar _sb = SnackBarService(message: "Failed To Save Right Data", color: Colors.red).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);

            print("GB: Send Right: Failed");

            throw FormatException("GB: Send Right: Failed");

          }

          newDataReceived = false;
          setState(() {});
        }


    }
    catch(e){
      SnackBar _sb = SnackBarService(message: "Failed To Save Right Data", color: Colors.red).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);
      print("GB: SEND RIGHT ${e.toString()}");
    }

  }

  void _start() async {

    connection!.output.add(Uint8List.fromList(utf8.encode(GearBoxMessage().start())));
    await connection!.output!.allSent;
    await Future.delayed(Duration(milliseconds: 250));


    Provider.of<FlyerConnectionProvider>(context,listen: false).setGBStart(false);

    setState(() {

    });
  }

  void _stop() async {

    connection!.output.add(Uint8List.fromList(utf8.encode(GearBoxMessage().stop())));
    await connection!.output!.allSent;
    await Future.delayed(Duration(milliseconds: 100));


    Provider.of<FlyerConnectionProvider>(context,listen: false).setGBStart(true);

    setState(() {

    });
  }

  void _onDataReceived(Uint8List data) {

    try {
      String _d = utf8.decode(data);

      if(_d==null || _d==""){
        throw FormatException('Invalid Packet');
      }

      if(_d == Acknowledgement().createPacket() || _d == Acknowledgement().createPacket(error: true)){

        //Allow if:
        //request settins data
        // or if acknowledgement (error or no error )

        _data.add(_d);
        newDataReceived = true;
      }

      //else ignore data

    }
    catch (e){

      print("Settings: onDataReceived: ${e.toString()}");
    }
  }

}


class FlyerRTFUI extends StatefulWidget {

  BluetoothConnection connection;
  Stream<Uint8List> stream;

  FlyerRTFUI({required this.connection, required this.stream});


  @override
  _FlyerRTFUIState createState() => _FlyerRTFUIState();
}

class _FlyerRTFUIState extends State<FlyerRTFUI> {

  String? _RTFval;

  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  late BluetoothConnection connection;
  late Stream<Uint8List> stream;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    connection = widget.connection;
    stream = widget.stream;

    try{
      stream!.listen(_onDataReceived).onDone(() {});
    }
    catch(e){

      print("RTF:ADVANCED OP: Listening init: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _data.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _RTFval = Provider.of<FlyerConnectionProvider>(context,listen: false).getRTF;

    return Container(

      height: MediaQuery.of(context).size.height*0.10,
      width: MediaQuery.of(context).size.width,

      padding: EdgeInsets.all(5),


      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          _customButton("receive", Icons.arrow_downward, _receive),
          _customIncrementDecrement(_RTFval),
          _customButton("send", Icons.arrow_upward, _send),
        ],
      ),
    );
  }

  void _send() async {

    if(_RTFval != null){


      try{
        String  _rtfMessage = RTFMessage(value: _RTFval!).createPacket();

        connection!.output.add(Uint8List.fromList(utf8.encode(_rtfMessage)));

        await connection!.output!.allSent;

        await Future.delayed(Duration(milliseconds: 100));

        if(newDataReceived){

          newDataReceived = false;
          String _d = _data.last;

          if (_d == null || _d == "") {
            SnackBar _sb = SnackBarService(message: "Invalid Packet", color: Colors.red).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);

            print("Invalid Packet");

            throw FormatException("RTF: Invalid Packet");
          }

          if (_d == Acknowledgement().createPacket()) {
            SnackBar _sb = SnackBarService(message: "Saved RTF", color: Colors.green).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);
          }
          else {
            SnackBar _sb = SnackBarService(message: "Failed To Save RTF Data", color: Colors.red).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);

            print("RTF Failed");

            throw FormatException("Send RTF Failed");
          }
        }

      }
      catch(e){

        SnackBar _sb = SnackBarService(message: "Failed To Save RTF Data", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(_sb);

        print("ADVANCED OPTION: RTF: ${e.toString()}");
      }


    }
    else{
      SnackBar _sb = SnackBarService(message: "Receive Data Before Pressing Send", color: Colors.red).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);
    }
  }

  void _receive() async {

    try{

      String _rc = RTFMessage(value: "").receiveRequest();

      connection!.output.add(Uint8List.fromList(utf8.encode(_rc)));

      await connection!.output!.allSent;

      await Future.delayed(Duration(milliseconds: 100));

      if(newDataReceived){

        newDataReceived = false;
        String _d = _data.last;

        if (_d == null || _d == "") {
          SnackBar _sb = SnackBarService(message: "Invalid Packet", color: Colors.red).snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);

          print("Invalid Packet");

          throw FormatException("RTF1: Invalid Packet");
        }

        var dt = RTFMessage(value: "").decode(_d);

        String? _rtfdata = dt["value"];

        if(_rtfdata==null){

          throw FormatException("RTF1: Invalid value");
        }

        Provider.of<FlyerConnectionProvider>(context,listen: false).setRTF(_rtfdata);
        _RTFval = _rtfdata.toString();


        setState(() {
        });
      }

    }
    catch(e){

      SnackBar _sb = SnackBarService(message: "Failed To Receive RTF Data", color: Colors.red).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);

      print("RTF: ${e.toString()}");
    }
  }


  void _increment(){


    try{
      if(_RTFval!=null){

        double _rtfdata = double.parse(_RTFval!);

        _rtfdata += 0.01;

        if(_rtfdata > settingsLimits["RTF"]![1]){

          SnackBar _sb = SnackBarService(message: "RTF Range ${settingsLimits["RTF"]}", color: Colors.red).snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);
        }
        else{

          Provider.of<FlyerConnectionProvider>(context,listen: false).setRTF(_rtfdata.toStringAsFixed(2));
          _RTFval = _rtfdata.toStringAsFixed(2);
          setState(() {

          });
        }
      }
    }
    catch(e){
      SnackBar _sb = SnackBarService(message: "Failed To Set RTF Data", color: Colors.red).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);
      print("increment: RTF: ${e.toString()}");
    }
  }

  void _decrement(){

    try{
      if(_RTFval!=null){

        double _rtfdata = double.parse(_RTFval!);

        _rtfdata -= 0.01;

        if(_rtfdata < settingsLimits["RTF"]![0]){

          SnackBar _sb = SnackBarService(message: "RTF Range ${settingsLimits["RTF"]}", color: Colors.red).snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);
        }
        else{

          Provider.of<FlyerConnectionProvider>(context,listen: false).setRTF(_rtfdata.toStringAsFixed(2));
          _RTFval = _rtfdata.toStringAsFixed(2);
          setState(() {

          });
        }
      }
    }
    catch(e){
      SnackBar _sb = SnackBarService(message: "Failed To Set RTF Data", color: Colors.red).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);
      print("decrement: RTF: ${e.toString()}");
    }
  }

  Widget _customButton(String label,IconData icon, VoidCallback function){

    return Container(
      width: MediaQuery.of(context).size.width*0.15,

      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: (){
                  function();
                },
                icon: Icon(
                    icon,
                    color: Colors.blue,
                ),

            ),
            Text(
                label,
                style: TextStyle(color: Colors.blue),
            ),
          ]
      ),

    );
  }

  Widget _customIncrementDecrement(String? _text){

    return Container(

      height: MediaQuery.of(context).size.height*0.06,
      width: MediaQuery.of(context).size.width*0.65,

      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          IconButton(
              onPressed: (){
                _increment();
              },
              icon: Icon(Icons.add, color: Theme.of(context).primaryColor,)
          ),

          Container(
            width: MediaQuery.of(context).size.width*0.3,
            height: MediaQuery.of(context).size.height*0.06,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Text(
              _text??"-",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
            alignment: Alignment.center,
          ),
          IconButton(
              onPressed: (){
                _decrement();
              },
              icon: Icon(Icons.remove, color: Theme.of(context).primaryColor,)
          ),
        ],
      ),
    );
  }

  void _onDataReceived(Uint8List data) {

    try {
      String _d = utf8.decode(data);

      if(_d==null || _d==""){
        throw FormatException('Invalid Packet');
      }

      if(_d == Acknowledgement().createPacket() || _d == Acknowledgement().createPacket(error: true) || _d.substring(4,6)==Information.RTF.hexVal){

        //Allow if:
        //request settins data
        // or if acknowledgement (error or no error )

        _data.add(_d);
        newDataReceived = true;
      }

      //else ignore data

    }
    catch (e){

      print("rtf : onDataReceived: ${e.toString()}");
    }
  }
}
