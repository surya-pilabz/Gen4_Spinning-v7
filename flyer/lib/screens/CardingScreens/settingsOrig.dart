import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/Carding/machineEnums.dart';

import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/Carding/settings_request.dart';
import 'package:flyer/message/Carding/settingsMessage.dart';
import 'package:flyer/screens/CardingScreens/settingsPopUpPage.dart';
import 'package:flyer/services/Carding/provider_service.dart';
import 'package:provider/provider.dart';

import '../../services/snackbar_service.dart';


class CardingSettingsPage extends StatefulWidget {

  BluetoothConnection connection;

  Stream<Uint8List> settingsStream;

  CardingSettingsPage({required this.connection, required this.settingsStream});

  @override
  _CardingSettingsPageState createState() => _CardingSettingsPageState();
}

class _CardingSettingsPageState extends State<CardingSettingsPage> {

  final TextEditingController _deliverySpeed = TextEditingController();
  final TextEditingController _draft = TextEditingController();
  final TextEditingController _cylinderSpeed = TextEditingController();
  final TextEditingController _beaterSpeed = TextEditingController();
  final TextEditingController _cylFeedSpeed = TextEditingController();
  final TextEditingController _btrFeedSpeed = TextEditingController();
  final TextEditingController _trunkSensorDelay = TextEditingController();
  final TextEditingController _lengthLimit = TextEditingController();
  final TextEditingController _rampTimes = TextEditingController();

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
      if(!Provider.of<CardingConnectionProvider>(context,listen: false).isSettingsEmpty){

        Map<String,String> _s = Provider.of<CardingConnectionProvider>(context,listen: false).settings;

        _deliverySpeed.text = _s["deliverySpeed"].toString();
        _draft.text =  _s["draft"].toString();
        _cylinderSpeed.text = _s["cylSpeed"].toString();
        _beaterSpeed.text = _s["btrSpeed"].toString();
        _cylFeedSpeed.text = _s["cylFeedSpeed"].toString();
        _btrFeedSpeed.text = _s["btrFeedSpeed"].toString();
        _trunkSensorDelay.text=_s["trunkDelay"].toString();
        _lengthLimit.text = _s["lengthLimit"].toString();
        _rampTimes.text = _s["rampTimes"].toString();
      }
    }
    catch(e){

      print("carding: settings: ${e.toString()}");
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
      bool _enabled = true; //only for carding

      bool _disable = Provider.of<CardingConnectionProvider>(context,listen: false).settingsChangeAllowed;


      return SingleChildScrollView(
        padding: EdgeInsets.only(left:screenHt *0.02,top: screenHt*0.01 ,bottom: screenHt*0.02, right: screenWidth*0.02),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 10),
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
                0: FractionColumnWidth(0.55),
                1: FractionColumnWidth(0.35),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                _customRow("DeliverySpeed (mtr/min)", _deliverySpeed,defaultValue: "",enabled: _enabled),
                _customRow("Draft", _draft,defaultValue: "",enabled: _enabled),
                _customRow("Card Cylinder RPM", _cylinderSpeed, isFloat: false,defaultValue: "",enabled: _disable),
                _customRow("Beater Cylinder RPM", _beaterSpeed, isFloat: false,defaultValue: "",enabled: _disable),
                _customRow("Card Feed RPM", _cylFeedSpeed,defaultValue: "",enabled: _enabled),
                _customRow("Beater Feed RPM", _btrFeedSpeed,defaultValue: "",enabled: _enabled),
                _customRow("Duct Sensor Delay(s)", _trunkSensorDelay,isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("Length Limit (mtrs)", _lengthLimit,isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("Ramp Times (sec)", _rampTimes,isFloat: false,defaultValue: "",enabled: _disable),
              ],
            ),

            Container(
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width,

              child: Row(
                mainAxisAlignment: _settingsButtons().length==1? MainAxisAlignment.end: MainAxisAlignment.spaceBetween,
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
              _deliverySpeed.text =  "8";
              _draft.text =  "1";
              _cylinderSpeed.text = "750";
              _beaterSpeed.text = "600";
              _cylFeedSpeed.text = "1.2";
              _btrFeedSpeed.text = "1.2";
              _trunkSensorDelay.text= "3";
              _lengthLimit.text = "100";
              _rampTimes.text = "5";

              SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, cylSpeed:_cylinderSpeed.text,beaterSpeed:_beaterSpeed.text,cylFeedSpeed:_cylFeedSpeed.text,btrFeedSpeed:_btrFeedSpeed.text,trunkDelay:_trunkSensorDelay.text,lengthLimit: _lengthLimit.text, rampTimes: _rampTimes.text);

              CardingConnectionProvider().setSettings(_sm.toMap());
              Provider.of<CardingConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

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


      //update
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

                SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, cylSpeed:_cylinderSpeed.text,beaterSpeed:_beaterSpeed.text,cylFeedSpeed:_cylFeedSpeed.text,btrFeedSpeed:_btrFeedSpeed.text,trunkDelay:_trunkSensorDelay.text,lengthLimit: _lengthLimit.text, rampTimes: _rampTimes.text);
                String _msg = _sm.createPacket(SettingsUpdate.update);


                CardingConnectionProvider().setSettings(_sm.toMap());
                Provider.of<CardingConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

                connection!.output.add(Uint8List.fromList(utf8.encode(_msg)));
                await connection!.output!.allSent.then((v) {});
                await Future.delayed(Duration(milliseconds: 500)); //wait for acknowledgement

                if(newDataReceived){
                  String _d = _data.last;

                  if(_d == Acknowledgement().createErrorPacket()){
                    //no eeprom error , acknowledge
                    SnackBar _sb = SnackBarService(message: "Settings Updated", color: Colors.green).snackBar();
                    ScaffoldMessenger.of(context).showSnackBar(_sb);

                  }
                  else{
                    //failed acknowledgement
                    SnackBar _sb = SnackBarService(message: "Settings Not Updated", color: Colors.red).snackBar();
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
            icon: Icon(Icons.system_update_alt,color: Theme.of(context).primaryColor,),
          ),
          Text(
            "Update",
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),

      //save button
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

                SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, cylSpeed:_cylinderSpeed.text,beaterSpeed:_beaterSpeed.text,cylFeedSpeed:_cylFeedSpeed.text,btrFeedSpeed:_btrFeedSpeed.text,trunkDelay:_trunkSensorDelay.text,lengthLimit: _lengthLimit.text, rampTimes: _rampTimes.text);
                String _msg = _sm.createPacket(SettingsUpdate.save);

                CardingConnectionProvider().setSettings(_sm.toMap());
                Provider.of<CardingConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

                connection!.output.add(Uint8List.fromList(utf8.encode(_msg)));
                await connection!.output!.allSent.then((v) {});
                await Future.delayed(Duration(milliseconds: 500)); //wait for acknowledgement

                if(newDataReceived){
                  String _d = _data.last;

                  if(_d == Acknowledgement().createErrorPacket()){
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

      //parameters button
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

                SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, cylSpeed:_cylinderSpeed.text,beaterSpeed:_beaterSpeed.text,cylFeedSpeed:_cylFeedSpeed.text,btrFeedSpeed:_btrFeedSpeed.text,trunkDelay:_trunkSensorDelay.text,lengthLimit: _lengthLimit.text, rampTimes: _rampTimes.text);

                CardingConnectionProvider().setSettings(_sm.toMap());
                Provider.of<CardingConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

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


  Dialog _popUpUI(){

    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height*0.8,
        width: MediaQuery.of(context).size.width*0.9,
        color: Colors.white,
        child: const CardingPopUpUI(),
      ),
    );
  }


  void _onDataReceived(Uint8List data) {

    try {
      String _d = utf8.decode(data);

      if(_d==null || _d==""){
        throw FormatException('Invalid Packet');
      }

      if(_d.substring(4,6)=="02" || _d == Acknowledgement().createErrorPacket() || _d == Acknowledgement().createErrorPacket(error: true)){

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
            margin: const EdgeInsets.only(left: 20, right: 20),
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
            margin: const EdgeInsets.only(top: 2.5,bottom: 2.5),
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

    if(_cylinderSpeed.text.trim() == "" ){
      errorMessage = "Cylinder RPM is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["cylSpeed"]!;
      double val = double.parse(_cylinderSpeed.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Cylinder RPM values should be within $range";
        return errorMessage;
      }
    }

    if(_cylFeedSpeed.text.trim() == "" ){
      errorMessage = "Card Feed RPM is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["cylFeedSpeed"]!;
      double val = double.parse(_cylFeedSpeed.text.trim());
      print(val);
      if(val < range[0] || val > range[1]){
        errorMessage = "Card Feed RPM values should be within $range";
        return errorMessage;
      }
    }

    if(_beaterSpeed.text.trim() == "" ){
      errorMessage = "Beater RPM is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["btrSpeed"]!;
      double val = double.parse(_beaterSpeed.text.trim());

      if(val < range[0] || val > range[1]){
      errorMessage = "Beater RPM values should be within $range";
      return errorMessage;
      }
    }

    if(_btrFeedSpeed.text.trim() == "" ){
      errorMessage = "Beater Feed RPM is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["btrFeedSpeed"]!;
      double val = double.parse(_btrFeedSpeed.text.trim());

      if(val < range[0] || val > range[1]){
      errorMessage = "Beater Feed RPM values should be within $range";
      return errorMessage;
      }
    }

    if(_trunkSensorDelay.text.trim() == "" ){
      errorMessage = "Trunk Sensor Delay is Empty!";
      return errorMessage;
      }
    else{
    List range = settingsLimits["trunkDelay"]!;
    double val = double.parse(_trunkSensorDelay.text.trim());

    if(val < range[0] || val > range[1]){
      errorMessage = "Trunk Sensor Delay values should be within $range";
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

    if(_rampTimes.text.trim() == "" ){
      errorMessage = "Ramp Times is Empty!";
      return errorMessage;
    }
    else{

      List range = settingsLimits["rampTimes"]!;
      double val = double.parse(_rampTimes.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Ramp Times values should be within $range";
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

        _deliverySpeed.text = settings["deliverySpeed"].toString();
        _draft.text = settings["draft"].toString();
        _cylinderSpeed.text = settings["cylSpeed"]!.toInt().toString();
        _beaterSpeed.text = settings["btrSpeed"]!.toInt().toString();
        _cylFeedSpeed.text = settings["cylFeedSpeed"].toString();
        _btrFeedSpeed.text = settings["btrFeedSpeed"].toString();
        _trunkSensorDelay.text = settings["trunkDelay"]!.toInt().toString();
        _lengthLimit.text = settings["lengthLimit"]!.toInt().toString();
        _rampTimes.text = settings["rampTimes"]!.toInt().toString();

        newDataReceived = false;


        SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, draft: _draft.text, cylSpeed:_cylinderSpeed.text,beaterSpeed:_beaterSpeed.text,cylFeedSpeed:_cylFeedSpeed.text,btrFeedSpeed:_btrFeedSpeed.text,trunkDelay:_trunkSensorDelay.text,lengthLimit: _lengthLimit.text, rampTimes: _rampTimes.text);

        CardingConnectionProvider().setSettings(_sm.toMap());
        Provider.of<CardingConnectionProvider>(context,listen: false).setSettings(_sm.toMap());


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
    int cylMaxRpm = 3500;
    double deliverySpeed = double.parse(_deliverySpeed.text);
    double draft = double.parse(_draft.text);
    double cylSpeed = double.parse(_cylinderSpeed.text);
    double btrSpeed = double.parse(_beaterSpeed.text);
    double cylFeedSpeed = double.parse(_cylFeedSpeed.text);
    double btrFeedSpeed = double.parse(_btrFeedSpeed.text);

    double cylinderGearRatio = 4;
    double beaterGearRatio = 4;
    double cylinderFeedGb = 120;
    double beaterFeedGb = 120;
    double tongueGrooveCircumferenceMm = 213.63;
    double cageGb = 5;
    double coilerGrooveCircumferenceMm = 194.779;
    double coilerGrooveToGbRatio = 1.656;
    double coilerGb = 6.91;

    double cylinderMotorRPM = cylSpeed*cylinderGearRatio;
    double beaterMotorRPM = btrSpeed*beaterGearRatio;
    double cylinderFeedMotorRPM = cylFeedSpeed * cylinderFeedGb;
    double beaterFeedMotorRPM = btrFeedSpeed * beaterFeedGb;
    double cageGbRpm = (deliverySpeed*1000)/tongueGrooveCircumferenceMm;
    double cageMotorRPM = cageGbRpm * cageGb;
    double reqCoilerTongueSurfaceSpeedMm = (deliverySpeed*1000) * draft;
    double reqCoilerTongueRpm = reqCoilerTongueSurfaceSpeedMm/coilerGrooveCircumferenceMm;
    double coilerGbRpm = reqCoilerTongueRpm/coilerGrooveToGbRatio;
    double coilerMotorRPM = coilerGbRpm * coilerGb;


    if(cylinderMotorRPM > cylMaxRpm){
      errorMessage = "Cylinder Motor RPM (${cylinderMotorRPM.toInt()}) exceeds  motor Max RPM ($cylMaxRpm). Check 'Parameters' page for more details.";
      return errorMessage;
     }
    if(beaterMotorRPM > cylMaxRpm){
      errorMessage = "Beater Motor RPM (${beaterMotorRPM.toInt()}) exceeds motor Max RPM ($cylMaxRpm). Check 'Parameters' page for more details";
      return errorMessage;
     }
    if(cylinderFeedMotorRPM > maxRPM){
      errorMessage = "Cylinder Feed Motor RPM (${cylinderFeedMotorRPM.toInt()}) exceeds motor Max RPM ($maxRPM). Check 'Parameters' page for more details";
      return errorMessage;
    }
    if(beaterFeedMotorRPM > maxRPM){
      errorMessage = "Beater Feed Motor RPM (${beaterFeedMotorRPM.toInt()}) exceeds motor Max RPM ($maxRPM). Check 'Parameters' page for more details";
      return errorMessage;
    }
    if(cageMotorRPM > maxRPM){
      errorMessage = "Cage Motor RPM (${cageMotorRPM.toInt()}) exceeds motor Max RPM ($maxRPM). Check 'Parameters' page for more details";
      return errorMessage;
    }
    if(coilerMotorRPM > maxRPM){
      errorMessage = "Coiler Motor RPM (${coilerMotorRPM.toInt()}) exceeds motor Max RPM ($maxRPM). Check 'Parameters' page for more details";
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




