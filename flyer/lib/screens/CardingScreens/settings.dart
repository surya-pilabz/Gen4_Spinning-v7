import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/Carding/machineEnums.dart';

import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/Carding/settings_request.dart';
import 'package:flyer/message/Carding/settingsMessage.dart';
import 'package:flyer/screens/CardingScreens/pid_settings.dart';
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
  final TextEditingController _cardFeedRatio = TextEditingController();
  final TextEditingController _lengthLimit = TextEditingController();
  final TextEditingController _cylSpeed = TextEditingController();
  final TextEditingController _btrSpeed = TextEditingController();
  final TextEditingController _pickerCylSpeed = TextEditingController();
  final TextEditingController _btrFeed = TextEditingController();
  final TextEditingController _afFeed = TextEditingController();

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
        print(_s);
        _deliverySpeed.text = _s["deliverySpeed"].toString();
        _cardFeedRatio.text =  _s["cardFeedRatio"].toString();
        _lengthLimit.text = _s["lengthLimit"].toString();
        _cylSpeed.text = _s["cylSpeed"].toString();
        _btrSpeed.text = _s["btrSpeed"].toString();
        _pickerCylSpeed.text=_s["pickerCylSpeed"].toString();
        _btrFeed.text = _s["btrFeed"].toString();
        _afFeed.text = _s["afFeed"].toString();
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
                0: FractionColumnWidth(0.75),
                1: FractionColumnWidth(0.22),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                _customRow("Delivery Speed (m/min)", _deliverySpeed, defaultValue: "", enabled: _enabled),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(
                                "Advanced Settings",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                            flex: 8,
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1.0,

                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const TableCell(child: SizedBox()), // Empty cell for alignment
                  ],
                ),
                _customRow("CardFeed Ratio", _cardFeedRatio, defaultValue: "", enabled: _enabled),
                _customRow("Length Limit (mtrs)", _lengthLimit, isFloat: false, defaultValue: "", enabled: _enabled),
                _customRow("Cylinder Speed (RPM)", _cylSpeed, isFloat: false, defaultValue: "", enabled: _disable),
                _customRow("Beater Speed (RPM)", _btrSpeed, isFloat: false, defaultValue: "", enabled: _disable),
                _customRow("Picker Cylinder Speed (RPM)", _pickerCylSpeed, isFloat: false, defaultValue: "", enabled: _disable),
                _customRow("Beater Feed (RPM)", _btrFeed, defaultValue: "", enabled: _enabled),
                _customRow("AF_Feed(RPM)", _afFeed, defaultValue: "", enabled: _enabled),
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
              _cardFeedRatio.text =  "5";
              _lengthLimit.text = "1000";
              _cylSpeed.text = "750";
              _btrSpeed.text = "600";
              _pickerCylSpeed.text= "600";
              _btrFeed.text = "10";
              _afFeed.text = "7";

              SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, cardFeedRatio: _cardFeedRatio.text, lengthLimit:_lengthLimit.text,cylSpeed:_cylSpeed.text,btrSpeed:_btrSpeed.text,pickerCylSpeed:_pickerCylSpeed.text,btrFeed:_btrFeed.text,afFeed: _afFeed.text);

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




      //save button
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              String _valid = isValidForm();
              //if settings are valid, try to see if the motor RPMs are correct
              // if(_valid == "valid"){
              //   _valid = calculate();
              // }
              if(_valid == "valid"){

                SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, cardFeedRatio: _cardFeedRatio.text, lengthLimit:_lengthLimit.text,cylSpeed:_cylSpeed.text,btrSpeed:_btrSpeed.text,pickerCylSpeed:_pickerCylSpeed.text,btrFeed:_btrFeed.text,afFeed: _afFeed.text);
                String _msg = _sm.createPacket(SettingsUpdate.save);

                CardingConnectionProvider().setSettings(_sm.toMap());
                Provider.of<CardingConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

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

      //PID Setting
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              _showPinDialog();
            },
            icon: Icon(Icons.system_update_alt,color: Theme.of(context).primaryColor,),
          ),
          Text(
            "PID",
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

                SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, cardFeedRatio: _cardFeedRatio.text, lengthLimit:_lengthLimit.text,cylSpeed:_cylSpeed.text,btrSpeed:_btrSpeed.text,pickerCylSpeed:_pickerCylSpeed.text,btrFeed:_btrFeed.text,afFeed: _afFeed.text);

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

    if(_cardFeedRatio.text.trim() == "" ){
      errorMessage = "cardFeedRatio is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["cardFeedRatio"]!;
      double val = double.parse(_cardFeedRatio.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "cardFeed Ratio values should be within $range";
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
        errorMessage = "length limit values should be within $range";
        return errorMessage;
      }
    }

    if(_cylSpeed.text.trim() == "" ){
      errorMessage = "Cylinder Speed is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["cylSpeed"]!;
      double val = double.parse(_cylSpeed.text.trim());
      print(val);
      if(val < range[0] || val > range[1]){
        errorMessage = "Cylinder speed values should be within $range";
        return errorMessage;
      }
    }

    if(_btrSpeed.text.trim() == "" ){
      errorMessage = "Beater RPM is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["btrSpeed"]!;
      double val = double.parse(_btrSpeed.text.trim());

      if(val < range[0] || val > range[1]){
      errorMessage = "Beater RPM values should be within $range";
      return errorMessage;
      }
    }

    if(_btrFeed.text.trim() == "" ){
      errorMessage = "Beater Feed RPM is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["btrFeed"]!;
      double val = double.parse(_btrFeed.text.trim());

      if(val < range[0] || val > range[1]){
      errorMessage = "Beater Feed RPM values should be within $range";
      return errorMessage;
      }
    }

    if(_pickerCylSpeed.text.trim() == "" ){
      errorMessage = "picker Cylinder  is Empty!";
      return errorMessage;
    }
    else{
      List range = settingsLimits["pickerCylSpeed"]!;
      double val = double.parse(_pickerCylSpeed.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Picker Cylinder values should be within $range";
        return errorMessage;
      }
    }

    if(_afFeed.text.trim() == "" ){
      errorMessage = "Af_Feed is Empty!";
      return errorMessage;
    }
    else{

      List range = settingsLimits["afFeed"]!;
      double val = double.parse(_afFeed.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Af Feed values should be within $range";
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
        _cardFeedRatio.text = settings["cardFeedRatio"].toString();
        _lengthLimit.text = settings["lengthLimit"]!.toInt().toString();
        _cylSpeed.text = settings["cylSpeed"]!.toInt().toString();
        _btrSpeed.text = settings["btrSpeed"]!.toInt().toString();
        _pickerCylSpeed.text = settings["pickerCylSpeed"]!.toInt().toString();
        _btrFeed.text = settings["btrFeed"]!.toInt().toString();
        _afFeed.text = settings["afFeed"]!.toInt().toString();

        newDataReceived = false;


        SettingsMessage _sm = SettingsMessage(deliverySpeed: _deliverySpeed.text, cardFeedRatio: _cardFeedRatio.text, lengthLimit:_lengthLimit.text,cylSpeed:_cylSpeed.text,btrSpeed:_btrSpeed.text,pickerCylSpeed:_pickerCylSpeed.text,btrFeed:_btrFeed.text,afFeed: _afFeed.text);

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
    double deliverySpeed = double.parse(_deliverySpeed.text);
    double draft = double.parse(_cardFeedRatio.text);
    double cylSpeed = double.parse(_cylSpeed.text);
    double btrSpeed = double.parse(_btrSpeed.text);
    // double cylFeedSpeed = double.parse(_cylFeedSpeed.text);
    // double btrFeedSpeed = double.parse(_btrFeedSpeed.text);

    double cylinderGearRatio = 1.2;
    double beaterGearRatio = 1.2;
    double cylinderFeedGb = 180;
    double beaterFeedGb = 180;
    double tongueGrooveCircumferenceMm = 213.63;
    double cageGb = 6.91;
    double coilerGrooveCircumferenceMm = 194.779;
    double coilerGrooveToGbRatio = 1.656;
    double coilerGb = 6.91;

    double cylinderMotorRPM = cylSpeed/cylinderGearRatio;
    double beaterMotorRPM = btrSpeed/beaterGearRatio;
    // double cylinderFeedMotorRPM = cylFeedSpeed * cylinderFeedGb;
    // double beaterFeedMotorRPM = btrFeedSpeed * beaterFeedGb;
    double cageGbRpm = (deliverySpeed*1000)/tongueGrooveCircumferenceMm;
    double cageMotorRPM = cageGbRpm * cageGb;
    double reqCoilerTongueSurfaceSpeedMm = (deliverySpeed*1000) * draft;
    double reqCoilerTongueRpm = reqCoilerTongueSurfaceSpeedMm/coilerGrooveCircumferenceMm;
    double coilerGbRpm = reqCoilerTongueRpm/coilerGrooveToGbRatio;
    double coilerMotorRPM = coilerGbRpm * coilerGb;


    if(cylinderMotorRPM > maxRPM){
      errorMessage = "Cylinder Motor RPM (${cylinderMotorRPM.toInt()}) exceeds  motor Max RPM ($maxRPM). Check 'Parameters' page for more details.";
      return errorMessage;
     }
    if(beaterMotorRPM > maxRPM){
      errorMessage = "Beater Motor RPM (${beaterMotorRPM.toInt()}) exceeds motor Max RPM ($maxRPM). Check 'Parameters' page for more details";
      return errorMessage;
     }
    // if(cylinderFeedMotorRPM > maxRPM){
    //   errorMessage = "Cylinder Feed Motor RPM (${cylinderFeedMotorRPM.toInt()}) exceeds motor Max RPM ($maxRPM). Check 'Parameters' page for more details";
    //   return errorMessage;
    // }
    // if(beaterFeedMotorRPM > maxRPM){
    //   errorMessage = "Beater Feed Motor RPM (${beaterFeedMotorRPM.toInt()}) exceeds motor Max RPM ($maxRPM). Check 'Parameters' page for more details";
    //   return errorMessage;
    // }
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

  // Show Pin Dialog

  void _showPinDialog() {
    final TextEditingController _pinController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool _isObscure = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter PIN',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: TextFormField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: _isObscure,
                  maxLength: 6,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter 6-digit PIN',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter PIN';
                    }
                    if (value.length != 6) {
                      return 'PIN must be 6 digits';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'PIN must contain only numbers';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Verify',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Replace '123456' with your actual PIN
                  if (_pinController.text == '123456') {
                    Navigator.of(context).pop();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>PIDSettingsCarding(
                          connection: connection,
                          settingsStream: settingsStream,
                        ),
                      ),
                    );

                    // Show success message
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBarService(
                    //     message: "PIN Verified Successfully",
                    //     color: Colors.green,
                    //   ).snackBar(),
                    // );
                    // Add your PID settings logic here
                    // You can navigate to PID settings page or show another dialog
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBarService(
                        message: "Invalid PIN",
                        color: Colors.red,
                      ).snackBar(),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
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




