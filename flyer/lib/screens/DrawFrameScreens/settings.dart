import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/DrawFrame/settings_request.dart';
import 'package:flyer/message/DrawFrame/settingsMessage.dart';
import 'package:flyer/screens/DrawFrameScreens/settingsPopUpPage.dart';
import 'package:flyer/services/DrawFrame/provider_service.dart';
import 'package:provider/provider.dart';

import '../../services/snackbar_service.dart';


class DrawFrameSettingsPage extends StatefulWidget {

  BluetoothConnection connection;

  Stream<Uint8List> settingsStream;

  DrawFrameSettingsPage({required this.connection, required this.settingsStream});

  @override
  _DrawFrameSettingsPageState createState() => _DrawFrameSettingsPageState();
}

class _DrawFrameSettingsPageState extends State<DrawFrameSettingsPage> {

  final TextEditingController _deliverySpeed = TextEditingController();
  final TextEditingController _draft = TextEditingController();
  final TextEditingController _lengthLimit = TextEditingController();
  final TextEditingController _rampUpTime = TextEditingController();
  final TextEditingController _rampDownTime = TextEditingController();
  final TextEditingController _creelTensionFactor = TextEditingController();


  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  late BluetoothConnection connection;
  late Stream<Uint8List> settingsStream;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try{
      connection = widget.connection;
      settingsStream = widget.settingsStream;
    }
    catch(e){
      print("Settings: Connection init: ${e.toString()}");
    }


    try{
      if(!Provider.of<DrawFrameConnectionProvider>(context,listen: false).isSettingsEmpty){

        Map<String,String> _s = Provider.of<DrawFrameConnectionProvider>(context,listen: false).settings;

        _deliverySpeed.text = _s["deliverySpeed"].toString();
        _draft.text =  _s["draft"].toString();
        _lengthLimit.text = _s["lengthLimit"].toString();
        _rampUpTime.text = _s["rampUpTime"].toString();
        _rampDownTime.text=_s["rampDownTime"].toString();
        _creelTensionFactor.text = _s["creelTensionFactor"].toString();
      }
    }
    catch(e){
      print("DF: Settings: ${e.toString()}");
    }


    try{
      settingsStream!.listen(_onDataReceived).onDone(() {});
    }
    catch(e){

      print("Settings: Listening init: ${e.toString()}");
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
    double screenHt  = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;


    if(connection!.isConnected){
      bool _enabled = Provider.of<DrawFrameConnectionProvider>(context,listen: false).settingsChangeAllowed;

      return SingleChildScrollView(
        padding: EdgeInsets.only(left:screenHt *0.02,top: screenHt*0.01 ,bottom: screenHt*0.02, right: screenWidth*0.02),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
              margin: const EdgeInsets.only(bottom: 10,top: 20),
              child: Center(
                child: Text(
                  "Settings",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.65),
                1: FractionColumnWidth(0.30),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                _customRow("DeliverySpeed (mtr/min)", _deliverySpeed, isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("Draft", _draft,defaultValue: "",enabled: _enabled),
                _customRow("Length Limit (mtrs)", _lengthLimit,isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("RampUp Time (sec)", _rampUpTime,isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("RampDown Time (sec)", _rampDownTime, isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("Creel Tension Factor", _creelTensionFactor,isFloat: true, defaultValue: "", enabled: _enabled),
              ],
            ),

            Container(
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: _settingsButtons(),
              ),
            ),
          ],
        ),
      );
    }
    else{
      return _checkConnection();
    }



  }

  List<Widget> _settingsButtons(){

    if(Provider.of<DrawFrameConnectionProvider>(context,listen: false).settingsChangeAllowed){
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () async {
                  _requestSettings();
                },
                icon: Icon(Icons.input, color: Theme.of(context).primaryColor,)
            ),
            Text(
              "Input",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: (){
                //hard coded change
                _deliverySpeed.text =  "80";
                _draft.text =  "8";
                _lengthLimit.text = "400";
                _rampUpTime.text = "6";
                _rampDownTime.text="6";
                _creelTensionFactor.text="1";

                SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, lengthLimit: _lengthLimit.text, rampUpTime: _rampUpTime.text, rampDownTime: _rampDownTime.text, creelTensionFactor: _creelTensionFactor.text);

                DrawFrameConnectionProvider().setSettings(_sm.toMap());
                Provider.of<DrawFrameConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

              },
              icon: Icon(Icons.settings_backup_restore,color: Theme.of(context).primaryColor,),
            ),
            Text(
              "Default",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                String _valid = isValidForm();
                //if settings are valid, try to see if the motor RPMs are correct
                if(_valid == "valid"){
                  _valid = calculate();
                }
                if(_valid == "valid"){

                  SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, lengthLimit: _lengthLimit.text, rampUpTime: _rampUpTime.text, rampDownTime: _rampDownTime.text, creelTensionFactor: _creelTensionFactor.text);
                  String _msg = _sm.createPacket();

                  DrawFrameConnectionProvider().setSettings(_sm.toMap());
                  Provider.of<DrawFrameConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

                  connection!.output.add(Uint8List.fromList(utf8.encode(_msg)));
                  await connection!.output!.allSent.then((v) {});
                  await Future.delayed(Duration(milliseconds: 500)); //wait for acknowledgement

                  if(newDataReceived){
                    String _d = _data.last;

                    if(_d == Acknowledgement().createPacket()){
                      //no eeprom error , acknowledge
                      SnackBar _sb = SnackBarService(message: "Settings Saved", color: Colors.green).snackBar();
                      ScaffoldMessenger.of(context).showSnackBar(_sb);

                    }
                    else{
                      //failed acknowledgement
                      SnackBar _sb = SnackBarService(message: "Settings Not Saved", color: Colors.red).snackBar();
                      ScaffoldMessenger.of(context).showSnackBar(_sb);
                    }

                    newDataReceived = false;
                    setState(() {
                    });
                  }

                }
                else{
                  SnackBar _sb = SnackBarService(message: _valid, color: Colors.red).snackBar();
                  ScaffoldMessenger.of(context).showSnackBar(_sb);
                }
              },
              icon: Icon(Icons.save,color: Theme.of(context).primaryColor,),
            ),
            Text(
              "Save",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: (){
                try{

                  String _err = isValidForm();

                  if(_err!="valid"){
                    //if error in form
                    SnackBar _snack = SnackBarService(message: _err, color: Colors.red).snackBar();
                    ScaffoldMessenger.of(context).showSnackBar(_snack);

                    throw FormatException(_err);
                  }

                  SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, lengthLimit: _lengthLimit.text, rampUpTime: _rampUpTime.text, rampDownTime: _rampDownTime.text, creelTensionFactor: _creelTensionFactor.text);

                  DrawFrameConnectionProvider().setSettings(_sm.toMap());
                  Provider.of<DrawFrameConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

                  showDialog(
                      context: context,
                      builder: (context) {
                        return _popUpUI();
                      }
                  );
                }
                catch(e){
                  print("Settings: search icon button: ${e.toString()}");
                }
              },
              icon: Icon(Icons.search,color: Theme.of(context).primaryColor,),
            ),
            Text(
              "Parameters",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

      ];
    }
    else{
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () async {
                  _requestSettings();
                },
                icon: Icon(Icons.input, color: Theme.of(context).primaryColor,)
            ),
            Text(
              "Input",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: (){
            try{

              String _err = isValidForm();

              if(_err!="valid"){
                //if error in form
                SnackBar _snack = SnackBarService(message: _err, color: Colors.red).snackBar();
                ScaffoldMessenger.of(context).showSnackBar(_snack);

                throw FormatException(_err);
              }

              SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, lengthLimit: _lengthLimit.text, rampUpTime: _rampUpTime.text, rampDownTime: _rampDownTime.text, creelTensionFactor: _creelTensionFactor.text);

              DrawFrameConnectionProvider().setSettings(_sm.toMap());
              Provider.of<DrawFrameConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

              showDialog(
                  context: context,
                  builder: (context) {
                    return _popUpUI();
                  }
              );
            }
            catch(e){
              print("Settings: search icon button: ${e.toString()}");
            }
          },
          icon: Icon(Icons.search,color: Theme.of(context).primaryColor,),
        ),
      ];
    }
  }


  Dialog _popUpUI(){

    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height*0.8,
        width: MediaQuery.of(context).size.width*0.9,
        color: Colors.white,
        child: const DrawFramePopUpUI(),
      ),
    );
  }


  void _onDataReceived(Uint8List data) {

    try {
      String _d = utf8.decode(data);

      if(_d==null || _d==""){
        throw FormatException('Invalid Packet');
      }

      if(_d.substring(4,6)=="02" || _d == Acknowledgement().createPacket() || _d == Acknowledgement().createPacket(error: true)){

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


  TableRow _customRow(String label, TextEditingController controller, {bool isFloat=true, String defaultValue="0", bool enabled=true}){

    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20,top: 10),
            child: Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child:
          Container(
            height: MediaQuery.of(context).size.height*0.05,
            width: MediaQuery.of(context).size.width*0.01,
            margin: const EdgeInsets.only(top: 12.5,bottom: 2.5),
            color: enabled? Colors.transparent : Colors.grey.shade400,
            child: TextField(
              enabled: enabled,
              controller: controller,
              inputFormatters:  <TextInputFormatter>[
              // for below version 2 use this

              isFloat?
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
              : FilteringTextInputFormatter.allow(RegExp(r'^\d+')),

              FilteringTextInputFormatter.deny('-'),
              // for version 2 and greater you can also use this

              ],
              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                //hintText: defaultValue,
              ),
            ),
          ),
        ),

      ],
    );
  }

  String isValidForm(){

    //checks if the entered values in the form are valid
    //returns appropriate error message if form is invalid
    //returns valid! if form is valid

    String errorMessage = "valid";

    if(_deliverySpeed.text.trim() == "" ){
      errorMessage = "Delivery Speed is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["deliverySpeed"]!;
      double val = double.parse(_deliverySpeed.text.trim());
      if(val < range[0] || val > range[1]){
        errorMessage = "Delivery Speed values should be within $range";
        return errorMessage;
      }
    }

    if(_draft.text.trim() == "" ){
      errorMessage = "Draft is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["draft"]!;
      double val = double.parse(_draft.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Draft values should be within $range";
        return errorMessage;
      }
    }

    if(_lengthLimit.text.trim() == "" ){
      errorMessage = "Length Limit is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["lengthLimit"]!;
      double val = double.parse(_lengthLimit.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Length Limit values should be within $range";
        return errorMessage;
      }
    }

    if(_rampUpTime.text.trim() == "" ){
      errorMessage = "RampUp Time is Empty!";
      return errorMessage;
    }
    else{

      List range = settingsLimits["rampUpTime"]!;
      double val = double.parse(_rampUpTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "RampUp Time values should be within $range";
        return errorMessage;
      }
    }

    if(_rampDownTime.text.trim() == "" ){
      errorMessage = "RampDown Time is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["rampDownTime"]!;
      double val = double.parse(_rampDownTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "RampDown Time values should be within $range";
        return errorMessage;
      }
    }


    if(_creelTensionFactor.text.trim() == "" ){
      errorMessage = "Creel Tension Factor is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["creelTensionFactor"]!;
      double val = double.parse(_creelTensionFactor.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Creel TensionFactor values should be within $range";
        return errorMessage;
      }
    }

    return errorMessage;
  }


  void _requestSettings() async {
    try {
      connection!.output.add(Uint8List.fromList(utf8.encode(RequestSettings().createPacket())));

      await connection!.output!.allSent;
      await Future.delayed(Duration(seconds: 1)); //wait for acknowlegement
      /*SnackBar _sb = SnackBarService(
          message: "Sent Request for Settings!", color: Colors.green)
          .snackBar();*/
      //ScaffoldMessenger.of(context).showSnackBar(_sb);


      if(newDataReceived){
        String _d = _data.last; //remember to make newDataReceived = false;

        Map<String, double> settings = RequestSettings().decode(_d);
        //settings = RequestSettings().decode(_d);


        if(settings.isEmpty){
          throw const FormatException("Settings Returned Empty");
        }


        _deliverySpeed.text = settings["deliverySpeed"]!.toInt().toString();
        _draft.text = settings["draft"].toString();
        _lengthLimit.text = settings["lengthLimit"]!.toInt().toString();
        _rampUpTime.text = settings["rampUpTime"]!.toInt().toString();
        _rampDownTime.text = settings["rampDownTime"]!.toInt().toString();
        _creelTensionFactor.text = settings["creelTensionFactor"]!.toDouble().toStringAsFixed(2);

        newDataReceived = false;


        SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, lengthLimit: _lengthLimit.text, rampUpTime: _rampUpTime.text, rampDownTime: _rampDownTime.text, creelTensionFactor: _creelTensionFactor.text);
        DrawFrameConnectionProvider().setSettings(_sm.toMap());
        Provider.of<DrawFrameConnectionProvider>(context,listen: false).setSettings(_sm.toMap());


        SnackBar _sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(_sb);

        setState(() {

        });
      }
      else{
        SnackBar _sb = SnackBarService(message: "Settings Not Received", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(_sb);

      }

    }
    catch(e){
      print("Settings!: ${e.toString()}");
      //Remember to change this error suppression
      if(e.toString() !=  "Bad state: Stream has already been listened to."){
        SnackBar sb = SnackBarService(message: "Error in Receiving Settings", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sb);
      }
      else{
        SnackBar sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sb);
        setState(() {

        });
      }

    }

  }


  String calculate(){

    //calculates rpm
    //always run this function in try catch. this is used to check if the motorRPMs
    // within the ability of the motor due to the settings we have input

    String errorMessage = "valid";

    int maxRPM = 1450;

    double deliveryspdMmin= double.parse(_deliverySpeed.text);
    double draft= double.parse(_draft.text);

    double frCircumference = 125.6;
    double brCircumference = 94.2;

    double frRpm = deliveryspdMmin * 1000/frCircumference;
    double frMotorRPM = frRpm * 1;
    double reqBrSurfacespeed = deliveryspdMmin*1000/draft;
    double brRPM = reqBrSurfacespeed/brCircumference;
    double brMotorRPM = brRPM * 6.91;

    if(frMotorRPM > maxRPM){
      errorMessage = "FrontRoller Motor RPM (${frMotorRPM.toInt()}) exceeds  motor Max RPM ($maxRPM). Check 'Parameters' page for more details.";
      return errorMessage;
     }
    if(brMotorRPM > maxRPM){
      errorMessage = "BackRoller Motor RPM (${brMotorRPM.toInt()}) exceeds motor Max RPM ($maxRPM). Check 'Parameters' page for more details";
      return errorMessage;
     }
    return errorMessage;
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

class CustomException implements Exception{
  String message;

  CustomException(this.message);

  @override
  String toString() {
    // TODO: implement toString
    return message;
  }
}




