import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/Flyer/settings_request.dart';
import 'package:flyer/message/Flyer/settingsMessage.dart';
import 'package:flyer/screens/FlyerScreens/settingsPopUpPage.dart';
import 'package:flyer/services/Flyer/provider_service.dart';
import 'package:provider/provider.dart';

import '../../services/snackbar_service.dart';


class FlyerSettingsPage extends StatefulWidget {

  BluetoothConnection connection;

  Stream<Uint8List> settingsStream;

  FlyerSettingsPage({required this.connection, required this.settingsStream});

  @override
  _FlyerSettingsPageState createState() => _FlyerSettingsPageState();
}

class _FlyerSettingsPageState extends State<FlyerSettingsPage> {

  final TextEditingController _spindleSpeed = TextEditingController();
  final TextEditingController _draft = TextEditingController();
  final TextEditingController _twistPerInch = TextEditingController();
  final TextEditingController _RTF = TextEditingController();
  final TextEditingController _layers = TextEditingController();
  final TextEditingController _maxHeightOfContent = TextEditingController();
  final TextEditingController _rovingWidth = TextEditingController();
  final TextEditingController _deltaBobbinDia = TextEditingController();
  final TextEditingController _bareBobbinDia = TextEditingController();
  final TextEditingController _rampupTime = TextEditingController();
  final TextEditingController _rampdownTime = TextEditingController();
  final TextEditingController _changeLayerTime = TextEditingController();
  final TextEditingController _coneAngleFactor = TextEditingController();

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
      if(!Provider.of<FlyerConnectionProvider>(context,listen: false).isSettingsEmpty){

        Map<String,String> _s = Provider.of<FlyerConnectionProvider>(context,listen: false).settings;

        _spindleSpeed.text = _s["spindleSpeed"].toString();
        _draft.text =  _s["draft"].toString();
        _twistPerInch.text = _s["twistPerInch"].toString();
        _RTF.text = _s["RTF"].toString();
        _layers.text=_s["layers"].toString();
        _maxHeightOfContent.text  = _s["maxHeightOfContent"].toString();
        _rovingWidth.text = _s["rovingWidth"].toString();
        _deltaBobbinDia.text = _s["deltaBobbinDia"].toString();
        _bareBobbinDia.text = _s["bareBobbinDia"].toString();
        _rampupTime.text= _s["rampupTime"].toString();
        _rampdownTime.text = _s["rampdownTime"].toString();
        _changeLayerTime.text = _s["changeLayerTime"].toString();
        _coneAngleFactor.text = _s["coneAngleFactor"].toString();
      }

    }
    catch(e){
      print("flyer: settings: init ${e.toString()}");
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
      bool _enabled = Provider.of<FlyerConnectionProvider>(context,listen: false).settingsChangeAllowed;

      return SingleChildScrollView(
        padding: EdgeInsets.only(left:screenHt *0.02,top: screenHt*0.01 ,bottom: screenHt*0.02, right: screenWidth*0.02),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
              margin: EdgeInsets.only(bottom: 5),
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
                _customRow("Spindle Speed (RPM)", _spindleSpeed, isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("Draft", _draft,defaultValue: "",enabled: _enabled),
                _customRow("Twists Per Inch", _twistPerInch,defaultValue: "",enabled: _enabled),
                _customRow("Initial RTF", _RTF,defaultValue: "",enabled: _enabled),
                _customRow("Layers", _layers, isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("Max Content Ht (mm)", _maxHeightOfContent, isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("Roving Width", _rovingWidth, defaultValue: "",enabled: _enabled),
                _customRow("Delta Bobbin-dia (mm)", _deltaBobbinDia,defaultValue: "",enabled: _enabled),
                _customRow("Bare Bobbin-dia (mm)", _bareBobbinDia, isFloat: false, defaultValue: "",enabled: _enabled),
                _customRow("Ramp Up Time (s)", _rampupTime, isFloat: false,defaultValue: "",enabled: _enabled),
                _customRow("Ramp Down Time (s)", _rampdownTime, isFloat: false, defaultValue: "",enabled: _enabled),
                _customRow("Change Layer Time (ms)", _changeLayerTime, isFloat: false, defaultValue: "",enabled: _enabled),
                _customRow("Cone Angle Factor", _coneAngleFactor, defaultValue: "",enabled: _enabled),

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

    if(Provider.of<FlyerConnectionProvider>(context,listen: false).settingsChangeAllowed){
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
                _spindleSpeed.text =  "650";
                _draft.text =  "8.8";
                _twistPerInch.text = "1.4";
                _RTF.text = "1";
                _layers.text="50";
                _maxHeightOfContent.text = "270";
                _rovingWidth.text = "1.2";
                _deltaBobbinDia.text = "1.1";
                _bareBobbinDia.text = "48";
                _rampupTime.text= "12";
                _rampdownTime.text = "12";
                _changeLayerTime.text = "800";
                _coneAngleFactor.text = "1";

                SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text,coneAngleFactor: _coneAngleFactor.text);

                FlyerConnectionProvider().setSettings(_sm.toMap());
                Provider.of<FlyerConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

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
                if(_valid == "valid"){
                  _valid = calculate();
                }
                if (_valid == "valid"){

                  SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text,coneAngleFactor: _coneAngleFactor.text);
                  String _msg = _sm.createPacket();

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

                  SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text,coneAngleFactor:_coneAngleFactor.text);

                  FlyerConnectionProvider().setSettings(_sm.toMap());
                  Provider.of<FlyerConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

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

              SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text,coneAngleFactor:_coneAngleFactor.text);

              FlyerConnectionProvider().setSettings(_sm.toMap());
              Provider.of<FlyerConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

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
        child: FlyerPopUpUI(),
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
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child:
          Container(
            height: MediaQuery.of(context).size.height*0.05,
            width: MediaQuery.of(context).size.width*0.01,
            margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
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

              decoration: InputDecoration(
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

    if(_spindleSpeed.text.trim() == "" ){
      errorMessage = "Spindle Speed is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["spindleSpeed"]!;
      double val = double.parse(_spindleSpeed.text.trim());
      if(val < range[0] || val > range[1]){
        errorMessage = "Spindle Speed values should be within $range";
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

    if(_twistPerInch.text.trim() == "" ){
      errorMessage = "Twist per Inch is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["twistPerInch"]!;
      double val = double.parse(_twistPerInch.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Twist per Inch values should be within $range";
        return errorMessage;
      }
    }

    if(_RTF.text.trim() == "" ){
      errorMessage = "RTF is Empty!";
      return errorMessage;
    }
    else{

      List range = settingsLimits["RTF"]!;
      double val = double.parse(_RTF.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "RTF values should be within $range";
        return errorMessage;
      }
    }

    if(_layers.text.trim() == "" ){
      errorMessage = "Layers is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["layers"]!;
      double val = double.parse(_layers.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Layers values should be within $range";
        return errorMessage;
      }
    }

    if(_maxHeightOfContent.text.trim() == "" ){
      errorMessage = "Max Height is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["maxHeightOfContent"]!;
      double val = double.parse(_maxHeightOfContent.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Max Height values should be within $range";
        return errorMessage;
      }
    }

    if(_rovingWidth.text.trim() == "" ){
      errorMessage = "Roving Width is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["rovingWidth"]!;
      double val = double.parse(_rovingWidth.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Roving Width values should be within $range";
        return errorMessage;
      }

    }

    if(_deltaBobbinDia.text.trim() == "" ){
      errorMessage = "Delta Bobbin Dia is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["deltaBobbinDia"]!;
      double val = double.parse(_deltaBobbinDia.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Delta Bobbin Dia values should be within $range";
        return errorMessage;
      }
    }

    if(_bareBobbinDia.text.trim() == "" ){
      errorMessage = "Bare Bobbin Dia is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["bareBobbinDia"]!;
      double val = double.parse(_bareBobbinDia.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Bare Bobbin Dia values should be within $range";
        return errorMessage;
      }
    }

    if(_rampupTime.text.trim() == "" ){
      errorMessage = "Rampup Time is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["rampupTime"]!;
      double val = double.parse(_rampupTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Ramp Up Time values should be within $range";
        return errorMessage;
      }
    }

    if(_rampdownTime.text.trim() == "" ){
      errorMessage = "Ramp Down Time is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["rampdownTime"]!;
      double val = double.parse(_rampdownTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Ramp Down Time values should be within $range";
        return errorMessage;
      }
    }

    if(_changeLayerTime.text.trim() == "" ){
      errorMessage = "Change Layer Time is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["changeLayerTime"]!;
      double val = double.parse(_changeLayerTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Change Layer values should be within $range";
        return errorMessage;
      }
    }

    if(_coneAngleFactor.text.trim() == "" ){
      errorMessage = "Cone Angle Factor is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["coneAngleFactor"]!;
      double val = double.parse(_coneAngleFactor.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Cone Angle Factor values should be within $range";
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

        print ("RECIEVED SETTINGS!");
        Map<String, double> settings = RequestSettings().decode(_d);
        //settings = RequestSettings().decode(_d);


        if(settings.isEmpty){
          throw const FormatException("Settings Returned Empty");
        }


        _spindleSpeed.text = settings["spindleSpeed"]!.toInt().toString();
        _draft.text = settings["draft"].toString();
        _twistPerInch.text = settings["twistPerInch"].toString();
        _RTF.text = settings["RTF"].toString();
        _layers.text = settings["layers"]!.toInt().toString();
        _maxHeightOfContent.text = settings["maxHeightOfContent"]!.toInt().toString();
        _rovingWidth.text = settings["rovingWidth"].toString();
        _deltaBobbinDia.text = settings["deltaBobbinDia"].toString();
        _bareBobbinDia.text = settings["bareBobbinDia"]!.toInt().toString();
        _rampupTime.text = settings["rampupTime"]!.toInt().toString();
        _rampdownTime.text = settings["rampdownTime"]!.toInt().toString();
        _changeLayerTime.text = settings["changeLayerTime"]!.toInt().toString();
        _coneAngleFactor.text = settings["coneAngleFactor"].toString();

        newDataReceived = false;


        SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text,coneAngleFactor: _coneAngleFactor.text);
        FlyerConnectionProvider().setSettings(_sm.toMap());
        Provider.of<FlyerConnectionProvider>(context,listen: false).setSettings(_sm.toMap());


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

    String errorMessage = "valid";
    //calculates rpm
    //always run this function in try catch
    double frCircumference = 94.248;
    double frRollerToMotorGearRatio = 4.61;

    var maxRPM = 1450;
    var strokeDistLimit = 5.5;
    
    var flyerMotorRPM = double.parse(_spindleSpeed.text) * 1.476;
    var deliveryMtrMin = (double.parse(_spindleSpeed.text)/ double.parse(_twistPerInch.text)) * 0.0254;

    double frRpm = (deliveryMtrMin * 1000) / frCircumference;
    var frMotorRpm = (frRpm * frRollerToMotorGearRatio);
    var brMotorRpm = ((frRpm * 23.562) / (double.parse(_draft.text)/ 1.5));

    double layerNo = 0; //layer 0 has highest speed for bobbin RPM so calculate only for that
    var bobbinDia = double.parse(_bareBobbinDia.text)+ layerNo * double.parse(_deltaBobbinDia.text);

    var deltaRpmSpindleBobbin = (deliveryMtrMin * 1000) /(bobbinDia * 3.14159);
    var bobbinRPM = double.parse(_spindleSpeed.text) + deltaRpmSpindleBobbin;
    var bobbinMotorRPM = bobbinRPM * 1.476;

    var strokeHeight = double.parse(_maxHeightOfContent.text) - ((double.parse(_rovingWidth.text) * double.parse(_coneAngleFactor.text)) * layerNo);
    var strokeDistPerSec = (deltaRpmSpindleBobbin * (double.parse(_rovingWidth.text) * double.parse(_coneAngleFactor.text))) / 60.0; //5.5
    var liftMotorRPM = (strokeDistPerSec * 60.0 / 4) * 15.3;

    int maxLayers = 0;
    var maxLayers_1 = double.parse(_maxHeightOfContent.text)/double.parse(_rovingWidth.text); // for stroke Ht != 0
    var maxLayers_2 = (140 - double.parse(_bareBobbinDia.text))/double.parse(_deltaBobbinDia.text); // for bobbin Circumference= max Width
    if (maxLayers_1 >= maxLayers_2){
      maxLayers = (maxLayers_2  - 5).ceil();
    }else{
      maxLayers = (maxLayers_1  - 5).ceil();
    }


    double userLayers = double.parse(_layers.text);
    if(flyerMotorRPM > maxRPM){
      errorMessage = "Flyer Motor RPM (${flyerMotorRPM.toInt()}) exceeds  motor Max RPM ($maxRPM). Check 'Parameters' page for more details.";
      return errorMessage;
    }
    if(frMotorRpm > maxRPM){
      errorMessage = "FR Motor RPM (${frMotorRpm.toInt()}) exceeds  motor Max RPM ($maxRPM). Check 'Parameters' page for more details.";
      return errorMessage;
    }
    if(brMotorRpm > maxRPM){
      errorMessage = "BR Motor RPM (${brMotorRpm.toInt()}) exceeds  motor Max RPM ($maxRPM). Check 'Parameters' page for more details.";
      return errorMessage;
    }
    if(bobbinMotorRPM > maxRPM){
      errorMessage = "Bobbin Motor RPM (${bobbinMotorRPM.toInt()}) exceeds  motor Max RPM ($maxRPM). Check 'Parameters' page for more details.";
      return errorMessage;
    }
    if(strokeDistPerSec > strokeDistLimit){
      errorMessage = "Stroke Speed (${strokeDistPerSec.toInt()}) exceeds Stroke Speed Limit ($strokeDistLimit). Check 'Parameters' page for more details.";
      return errorMessage;
    }
    if(userLayers > maxLayers){
      errorMessage = "No of Layers (${userLayers.toInt()}) exceeds Max Possible Layers ($maxLayers). Check 'Parameters' page for more details.";
      return errorMessage;
    }
    if(liftMotorRPM> maxRPM){
      errorMessage = "Stroke Speed (${liftMotorRPM.toInt()}) exceeds  motor Max RPM ($maxRPM). Check 'Parameters' page for more details.";
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




