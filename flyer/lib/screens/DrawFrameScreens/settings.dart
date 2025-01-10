import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/DrawFrame/enums.dart';

import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/DrawFrame/settings_request.dart';
import 'package:flyer/message/DrawFrame/settingsMessage.dart';
import 'package:flyer/message/DrawFrame/PID_settings_message.dart';
import 'package:flyer/screens/DrawFrameScreens/settingsPopUpPage.dart';
import 'package:flyer/services/DrawFrame/provider_service.dart';
import 'package:provider/provider.dart';

import '../../services/snackbar_service.dart';


class DrawFrameSettingsPage extends StatefulWidget {

  BluetoothConnection connection;
  Stream<Uint8List> settingsStream;
  DrawFrameSettingsPage({super.key, required this.connection, required this.settingsStream});

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

  //PID settingsUI widgets
  final TextEditingController kP_ = TextEditingController();
  final TextEditingController kI_ = TextEditingController();
  final TextEditingController feedForward_ = TextEditingController();
  final TextEditingController startOffset_ = TextEditingController();

  final List<String> _motorName = ["FRONT ROLLER","BACK ROLLER","CREEL"];
  late String selectedDropDownMotor = _motorName.first;
  late String previousDropDownMotor = _motorName.first;

  late PidSettings p0;

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
      settingsStream.listen(_onDataReceived).onDone(() {});
    }
    catch(e){

      print("Settings: Listening init: ${e.toString()}");
    }

    p0 = PidSettings(motorName: selectedDropDownMotor, kP: "0", kI: "0", feedForward: "0", startOffset: "0");

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

    if(connection.isConnected) {
      bool _enabled = Provider
          .of<DrawFrameConnectionProvider>(context, listen: false)
          .settingsChangeAllowed;
      return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              bottom: TabBar(
                  tabs:[
                    Tab(text:'Process'),
                    Tab(text:'PID'),
              ]),
            ),
            body: TabBarView(
                children: [   // first child is tab 1, second is tab 2
                  Center(
                    child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                Table(
                                columnWidths: const <int, TableColumnWidth>{
                                  0: FractionColumnWidth(0.65),
                                  1: FractionColumnWidth(0.30),
                                },
                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                  children: <TableRow>[
                                    customRow("DeliverySpeed (mtr/min)", _deliverySpeed, isFloat: false,defaultValue: "",enabled: _enabled),
                                    customRow("Draft", _draft,defaultValue: "",enabled: _enabled),
                                    customRow("Length Limit (mtrs)", _lengthLimit,isFloat: false,defaultValue: "",enabled: _enabled),
                                    customRow("RampUp Time (sec)", _rampUpTime,isFloat: false,defaultValue: "",enabled: _enabled),
                                    customRow("RampDown Time (sec)", _rampDownTime, isFloat: false,defaultValue: "",enabled: _enabled),
                                    customRow("Creel Tension Factor", _creelTensionFactor,isFloat: true, defaultValue: "", enabled: _enabled),
                                  ],
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height*0.1,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Container(
                                    margin: const EdgeInsets.all(10),
                                    height: MediaQuery.of(context).size.height*0.1,
                                    width: MediaQuery.of(context).size.width,

                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: _settingsButtons(),
                                    )
                                ),
                              ]
                          )
                  ),
                  Center(
                      child:
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Table(
                                columnWidths: const <int, TableColumnWidth>{
                                  0: FractionColumnWidth(0.65),
                                  1: FractionColumnWidth(0.30),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: <TableRow>[
                                  customRowWithDropDown("MotorName",_motorName),
                                  customRow("Kp ", kP_, isFloat:true,defaultValue: "",enabled: _enabled),
                                  customRow("Ki", kI_,isFloat:true,defaultValue: "",enabled: _enabled),
                                  customRow("Feed Forward", feedForward_,isFloat: false,defaultValue: "",enabled: _enabled),
                                  customRow("Start Offset", startOffset_,isFloat: false,defaultValue: "",enabled: _enabled),
                                ],
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height*0.1,
                                width: MediaQuery.of(context).size.width,
                              ),
                              Container(
                                  margin: const EdgeInsets.all(10),
                                  height: MediaQuery.of(context).size.height*0.1,
                                  width: MediaQuery.of(context).size.width,

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: _settingsButtonsPID(),
                                  )
                              ),
                            ]
                  ),
                  )
                ],
            )
          )
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
                  requestProcessSettings();
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

                  connection.output.add(Uint8List.fromList(utf8.encode(_msg)));
                  await connection.output.allSent.then((v) {});
                  await Future.delayed(const Duration(milliseconds: 500)); //wait for acknowledgement

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
                  requestProcessSettings();
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

  List<Widget> _settingsButtonsPID(){
    if(Provider.of<DrawFrameConnectionProvider>(context,listen: false).settingsChangeAllowed){
      return [
        Row(
          children:[
            Container(
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width/2,
              margin: const EdgeInsets.only(left:15),
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () async {
                        requestPIDSettings();
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
            ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      sendPIDSettings();
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
          ])];
    }
    else{
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () async {
                  requestPIDSettings();
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

  TableRow customRow(String label, TextEditingController controller, {bool isFloat=true, String defaultValue="0", bool enabled=true}){
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
  TableRow customRowWithDropDown(String label, List<String> dropDownList, {bool enabled=true}) {
    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child:
          Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.05,
            width: MediaQuery
                .of(context)
                .size
                .width * 0.2,
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            child: DropdownButton<String>(
              value: selectedDropDownMotor,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              alignment: FractionalOffset.topLeft,
              style: const TextStyle(color: Colors.lightGreen),
              underline: Container(),
              isExpanded: true,
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  selectedDropDownMotor = value!;
                  doSomething();
                });
              },
              items: dropDownList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

void doSomething(){
      if (previousDropDownMotor != selectedDropDownMotor){
        kP_.text = "";
        kI_.text = "";
        feedForward_.text = "";
        startOffset_.text = "";
        previousDropDownMotor = selectedDropDownMotor;
      }
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

  void requestProcessSettings() async {
    try {
      connection.output.add(Uint8List.fromList(utf8.encode(RequestSettings().createPacket())));

      await connection.output.allSent;
      await Future.delayed(const Duration(seconds: 1)); //wait for acknowlegement
      /*SnackBar sB_ = SnackBarService(
          message: "Sent Request for Settings!", color: Colors.green)
          .snackBar();*/
      //ScaffoldMessenger.of(context).showSnackBar(sB_);


      if(newDataReceived){
        String _d = _data.last; //remember to make newDataReceived = false;

        Map<String, double> settings = RequestSettings().decode(_d);

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

        SnackBar sB_ = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sB_);

        setState(() {

        });
      }
      else{
        SnackBar sB = SnackBarService(message: "Settings Not Received", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sB);

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

  void requestPIDSettings() async {
    try {
      p0.motorName = selectedDropDownMotor;
      connection.output.add(Uint8List.fromList(utf8.encode(p0.createRequestPacket())));

      await connection.output.allSent;
      await Future.delayed(const Duration(seconds: 2)); //wait for acknowlegement for two sec
      /*SnackBar sB = SnackBarService(
          message: "Sent Request for Settings!", color: Colors.green)
          .snackBar();
      ScaffoldMessenger.of(context).showSnackBar(sB);*/

      if(newDataReceived){
        String _d = _data.last; //remember to make newDataReceived = false;
        Map<String, double> settings = p0.decodePacket(_d);

        if(settings.isEmpty){
          throw const FormatException("Settings Returned Empty");
        }

        kP_.text = settings["kP"]!.toInt().toString();
        kI_.text = settings["kI"]!.toInt().toString();
        feedForward_.text = settings["feedForward"]!.toInt().toString();
        startOffset_.text = settings["startOffset"]!.toInt().toString();

        newDataReceived = false;

        //DrawFrameConnectionProvider().setSettings(_sm.toMap());
       // Provider.of<DrawFrameConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

        SnackBar sB = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sB);

        setState(() {

        });
      }
      else{
        SnackBar sB = SnackBarService(message: "Settings Not Received", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sB);

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

  String isValidFormPid(){

    //checks if the entered values in the form are valid
    //returns appropriate error message if form is invalid
    //returns valid! if form is valid

    String errorMessage = "valid";

    if(kP_.text.trim() == "" ){
      errorMessage = "Kp is Empty!";
      return errorMessage;
    }
    else{
      List range = pidSettingsLimits["Kp"]!;
      double val = double.parse(kP_.text.trim());
      if(val < range[0] || val > range[1]){
        errorMessage = "Kp values should be within $range";
        return errorMessage;
      }
    }

    if(kI_.text.trim() == "" ){
      errorMessage = "Ki is Empty!";
      return errorMessage;
    }
    else{
      List range = pidSettingsLimits["Ki"]!;
      double val = double.parse(kI_.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Draft values should be within $range";
        return errorMessage;
      }
    }

    if(startOffset_.text.trim() == "" ){
      errorMessage = "Start Offset is Empty!";
      return errorMessage;
    }
    else{
      List range = pidSettingsLimits["SO"]!;
      double val = double.parse(startOffset_.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Start Offset values should be within $range";
        return errorMessage;
      }
    }

    if(feedForward_.text.trim() == "" ){
      errorMessage = "Feed Forward is Empty!";
      return errorMessage;
    }
    else{

      List range = pidSettingsLimits["FF"]!;
      double val = double.parse(feedForward_.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Feed Forward values should be within $range";
        return errorMessage;
      }
    }

    return errorMessage;
  }

  void sendPIDSettings() async {
    try {
      String _valid = isValidFormPid();
      if (_valid == "valid") {
        p0.kP = kP_.text;
        p0.kI = kI_.text;
        p0.feedForward = feedForward_.text;
        p0.startOffset = startOffset_.text;
        p0.motorName = selectedDropDownMotor;

        String _msg = p0.createNewPidPacket();

        //what does this do?
        //DrawFrameConnectionProvider().setSettings(_sm.toMap());
        //Provider.of<DrawFrameConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

        connection.output.add(Uint8List.fromList(utf8.encode(_msg)));
        await connection.output.allSent;
        await Future.delayed(const Duration(seconds: 2)); //wait for acknowledgement

        if (newDataReceived) {
          String _d = _data.last;

          if (_d == Acknowledgement().createErrorPacket()) {
            //no eeprom error , acknowledge
            SnackBar _sb = SnackBarService(
                message: "Settings Saved", color: Colors.green).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);
          }
          else {
            //failed acknowledgement
            SnackBar _sb = SnackBarService(
                message: "Settings Not Saved", color: Colors.red).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);
          }

          newDataReceived = false;
          setState(() {});
        }
      }
      else { // invalid data
        SnackBar _sb = SnackBarService(message: _valid, color: Colors.red)
            .snackBar();
        ScaffoldMessenger.of(context).showSnackBar(_sb);
      }
     }
      catch(e) {
        print("Sending Settings!: ${e.toString()}");
      }

  }




  void _onDataReceived(Uint8List data) {
    try {
      String _d = utf8.decode(data);
      if(_d==""){
        throw const FormatException('Invalid Packet');
      }
      String information = _d.substring(4,6);
      if(information==Information.settingsToApp.hexVal || information == Information.pidResponse.hexVal ||
          _d == Acknowledgement().createErrorPacket() || _d == Acknowledgement().createErrorPacket(error: true)){

        //Allow if:
        //request settings data
        //pid request
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
            const SizedBox(
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




