import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/RingDoubler/settings_request.dart';
import 'package:flyer/message/RingDoubler/settingsMessage.dart';
import 'package:flyer/screens/RingDoublerScreens/settingsPopUpPage.dart';
import 'package:flyer/services/RingDoubler/provider_service.dart';
import 'package:provider/provider.dart';

import '../../services/snackbar_service.dart';

class RingDoublerSettingsPage extends StatefulWidget {
  BluetoothConnection connection;

  Stream<Uint8List> settingsStream;

  RingDoublerSettingsPage({required this.connection, required this.settingsStream});

  @override
  _RingDoublerSettingsPageState createState() => _RingDoublerSettingsPageState();
}

class _RingDoublerSettingsPageState extends State<RingDoublerSettingsPage> {
  
  
  final TextEditingController _inputYarnCount = TextEditingController();
  final TextEditingController _outputYarnDia = TextEditingController();

  final TextEditingController _twistPerInch = TextEditingController();
  final TextEditingController _packageHeight = TextEditingController();
  final TextEditingController _diaBuildFactor = TextEditingController();
  final TextEditingController _windingClosenessFactor = TextEditingController();
  final TextEditingController _windingOffsetCoils = TextEditingController();
  
  
  List<String> _spindleSpeeds = ["6000","8000","10000","12000"];
  late String _spindleSpeedChoice = _spindleSpeeds.first;

  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  late BluetoothConnection connection;
  late Stream<Uint8List> settingsStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try {
      connection = widget.connection;
      settingsStream = widget.settingsStream;
    } catch (e) {
      print("Settings: Connection init: ${e.toString()}");
    }

    try{
      if (!Provider.of<RingDoublerConnectionProvider>(context, listen: false).isSettingsEmpty) {

        Map<String, String> _s = Provider.of<RingDoublerConnectionProvider>(context, listen: false).settings;

        _inputYarnCount.text = _s["inputYarnCount"].toString();
        _outputYarnDia.text = _s["outputYarnDia"].toString();
        _spindleSpeedChoice = _s["spindleSpeed"].toString();
        _twistPerInch.text = _s["twistPerInch"].toString();
        _packageHeight.text = _s["packageHeight"].toString();
        _diaBuildFactor.text = _s["diaBuildFactor"].toString();
        _windingClosenessFactor.text = _s["windingClosenessFactor"].toString();
        _windingOffsetCoils.text = _s["windingOffsetCoils"].toString();
      }

    }
    catch(e){
      print("RD: Settings: init ${e.toString()}");
    }

    try {
      settingsStream!.listen(_onDataReceived).onDone(() {});
    } catch (e) {
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
    double screenHt = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (connection!.isConnected) {

      bool _enabled = Provider.of<RingDoublerConnectionProvider>(context, listen: false).settingsChangeAllowed;

      
      return SingleChildScrollView(
        padding: EdgeInsets.only(
            left: screenHt * 0.02,
            top: screenHt * 0.01,
            bottom: screenHt * 0.02,
            right: screenWidth * 0.02),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20,top: 10),
              height: MediaQuery.of(context).size.height*0.05,
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
                0: FractionColumnWidth(0.60),
                1: FractionColumnWidth(0.35),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                _customRow("Input Yarn Count (Ne)", _inputYarnCount, isFloat: false, defaultValue: "", enabled: _enabled,inputYarn: true),
                _customRow("Ouput Yarn Dia (mm)", _outputYarnDia, isFloat: true, defaultValue: "", enabled: _enabled),
                TableRow(
                  children: <Widget>[

                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Text(
                          "Spindle Speed (RPM)",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child:
                      Container(
                        height: MediaQuery.of(context).size.height*0.05,
                        width: MediaQuery.of(context).size.width*0.2,
                        margin: EdgeInsets.only(top: 5,bottom: 5),
                        padding: EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: _spindleSpeedChoice,
                          icon: const Icon(Icons.arrow_drop_down,size: 25,),
                          elevation: 16,
                          alignment: FractionalOffset.topCenter,
                          style: const TextStyle(color: Colors.lightGreen),
                          underline: Container(),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              _spindleSpeedChoice = value!;
                            });
                          },
                          items: _spindleSpeeds.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: 18),),
                            );
                          }).toList(),

                        ),
                      ),
                    ),

                  ],
                ),
                
                _customRow("Twists Per Inch", _twistPerInch, isFloat: false, defaultValue: "", enabled: _enabled),
                _customRow("Package Height (mm)", _packageHeight, isFloat: false, defaultValue: "", enabled: _enabled),
                _customRow("Dia Build Factor ", _diaBuildFactor, defaultValue: "", enabled: _enabled),
                _customRow("Winding Closeness Factor", _windingClosenessFactor, isFloat: false, defaultValue: "", enabled: _enabled),
                _customRow("Winding Offset Coils", _windingOffsetCoils, isFloat: false, defaultValue: "", enabled: _enabled),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.05,
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.1,
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
    } else {
      return _checkConnection();
    }
  }

  List<Widget> _settingsButtons() {
    if (Provider.of<RingDoublerConnectionProvider>(context, listen: false).settingsChangeAllowed) {
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () async {
                  _requestSettings();
                },
                icon: Icon(
                  Icons.input,
                  color: Theme.of(context).primaryColor,
                )),
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
              onPressed: () {
                //hard coded change
                _inputYarnCount.text = "20";
                _outputYarnDia.text = "0.40";
                _spindleSpeedChoice= "6000";
                _twistPerInch.text = "14";
                _packageHeight.text = "200";
                _diaBuildFactor.text = "0.12";
                _windingClosenessFactor.text = "108";
                _windingOffsetCoils.text = "2";

                SettingsMessage _sm = SettingsMessage(
                    inputYarn: _inputYarnCount.text,
                    outputYarnDia: _outputYarnDia.text,
                    spindleSpeed: _spindleSpeedChoice,
                    twistPerInch: _twistPerInch.text,
                    packageHt: _packageHeight.text,
                    diaBuildFactor: _diaBuildFactor.text,
                    windingClosenessFactor: _windingClosenessFactor.text,
                    windingOffsetCoils: _windingOffsetCoils.text);

                // if the user changes the value
                _outputYarnDia.text = _sm.outputYarnDia ?? "";

                RingDoublerConnectionProvider().setSettings(_sm.toMap());

                Provider.of<RingDoublerConnectionProvider>(context, listen: false).setSettings(_sm.toMap());
              },
              icon: Icon(
                Icons.settings_backup_restore,
                color: Theme.of(context).primaryColor,
              ),
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
                if (_valid == "valid") {
                  _valid = calculate();
                }
                if (_valid == "valid") {
                  SettingsMessage _sm = SettingsMessage(
                    inputYarn: _inputYarnCount.text,
                    outputYarnDia: _outputYarnDia.text,
                    spindleSpeed: _spindleSpeedChoice,
                    twistPerInch: _twistPerInch.text,
                    packageHt: _packageHeight.text,
                    diaBuildFactor: _diaBuildFactor.text,
                    windingClosenessFactor: _windingClosenessFactor.text,
                    windingOffsetCoils: _windingOffsetCoils.text,
                  );

                  //update value if it is calculated
                  _outputYarnDia.text = _sm.outputYarnDia ?? "";

                  String _msg = _sm.createPacket();

                  RingDoublerConnectionProvider().setSettings(_sm.toMap());

                  Provider.of<RingDoublerConnectionProvider>(context, listen: false).setSettings(_sm.toMap());

                  connection!.output.add(Uint8List.fromList(utf8.encode(_msg)));
                  await connection!.output!.allSent.then((v) {});
                  await Future.delayed(
                      Duration(milliseconds: 500)); //wait for acknowledgement

                  if (newDataReceived) {
                    String _d = _data.last;

                    if (_d == Acknowledgement().createPacket()) {
                      //no eeprom error , acknowledge
                      SnackBar _sb = SnackBarService(
                              message: "Settings Saved", color: Colors.green)
                          .snackBar();
                      ScaffoldMessenger.of(context).showSnackBar(_sb);
                    } else {
                      //failed acknowledgement
                      SnackBar _sb = SnackBarService(
                              message: "Settings Not Saved", color: Colors.red)
                          .snackBar();
                      ScaffoldMessenger.of(context).showSnackBar(_sb);
                    }

                    newDataReceived = false;
                    setState(() {});
                  }
                } else {
                  SnackBar _sb =
                      SnackBarService(message: _valid, color: Colors.red)
                          .snackBar();
                  ScaffoldMessenger.of(context).showSnackBar(_sb);
                }
              },
              icon: Icon(
                Icons.save,
                color: Theme.of(context).primaryColor,
              ),
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
              onPressed: () {
                try {
                  String _err = isValidForm();

                  if (_err != "valid") {
                    //if error in form
                    SnackBar _snack =
                        SnackBarService(message: _err, color: Colors.red)
                            .snackBar();
                    ScaffoldMessenger.of(context).showSnackBar(_snack);

                    throw FormatException(_err);
                  }
                  SettingsMessage _sm = SettingsMessage(
                      inputYarn: _inputYarnCount.text,
                      outputYarnDia: _outputYarnDia.text,
                      spindleSpeed: _spindleSpeedChoice,
                      twistPerInch: _twistPerInch.text,
                      packageHt: _packageHeight.text,
                      diaBuildFactor: _diaBuildFactor.text,
                      windingClosenessFactor: _windingClosenessFactor.text,
                      windingOffsetCoils: _windingOffsetCoils.text);

                  //update
                  _outputYarnDia.text = _sm.outputYarnDia ?? "";

                  RingDoublerConnectionProvider().setSettings(_sm.toMap());
                  Provider.of<RingDoublerConnectionProvider>(context, listen: false)
                      .setSettings(_sm.toMap());

                  showDialog(
                      context: context,
                      builder: (context) {
                        return _popUpUI();
                      });
                } catch (e) {
                  print("Settings: search icon button: ${e.toString()}");
                }
              },
              icon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
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

    else {
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () async {
                  _requestSettings();
                },
                icon: Icon(
                  Icons.input,
                  color: Theme.of(context).primaryColor,
                )),
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
              onPressed: () {
                try {
                  String _err = isValidForm();

                  if (_err != "valid") {
                    //if error in form
                    SnackBar _snack =
                    SnackBarService(message: _err, color: Colors.red)
                        .snackBar();
                    ScaffoldMessenger.of(context).showSnackBar(_snack);

                    throw FormatException(_err);
                  }

                  SettingsMessage _sm = SettingsMessage(
                    inputYarn: _inputYarnCount.text,
                    outputYarnDia: _outputYarnDia.text,
                    spindleSpeed: _spindleSpeedChoice,
                    twistPerInch: _twistPerInch.text,
                    packageHt: _packageHeight.text,
                    diaBuildFactor: _diaBuildFactor.text,
                    windingClosenessFactor: _windingClosenessFactor.text,
                    windingOffsetCoils: _windingOffsetCoils.text,
                  );

                  //update
                  _outputYarnDia.text = _sm.outputYarnDia??"";

                  RingDoublerConnectionProvider().setSettings(_sm.toMap());
                  Provider.of<RingDoublerConnectionProvider>(context, listen: false)
                      .setSettings(_sm.toMap());

                  showDialog(
                      context: context,
                      builder: (context) {
                        return _popUpUI();
                      });
                } catch (e) {
                  print("Settings: search icon button: ${e.toString()}");
                }
              },
              icon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              "parameters",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        )
      ];
    }
  }

  Dialog _popUpUI() {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.9,
        color: Colors.white,
        child: RDPopUpUI(),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    try {
      String _d = utf8.decode(data);

      if (_d == null || _d == "") {
        throw FormatException('Invalid Packet');
      }

      if (_d.substring(4, 6) == "02" ||
          _d == Acknowledgement().createPacket() ||
          _d == Acknowledgement().createPacket(error: true)) {
        //Allow if:
        //request settins data
        // or if acknowledgement (error or no error )

        _data.add(_d);
        newDataReceived = true;
      }

      //else ignore data

    } catch (e) {
      print("Settings: onDataReceived: ${e.toString()}");
    }
  }

  TableRow _customRow(String label, TextEditingController controller, {bool isFloat = true, String defaultValue = "0", bool enabled = true, bool inputYarn = false}) {
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
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.01,
            margin: EdgeInsets.only(top: 2.5, bottom: 2.5),
            color: enabled ? Colors.transparent : Colors.grey.shade400,
            child: TextField(
              onChanged: (val){

                if(inputYarn){
                  //change output yarn dia -> note only used for ring doubler settings

                  try {
                    _outputYarnDia.text = (-0.10284 + 1.592 / sqrt(double.parse(val) / 2)).toStringAsFixed(2);
                  }
                  catch(e){


                  }
                }

              },
              enabled: enabled,
              controller: controller,
              inputFormatters: <TextInputFormatter>[
                // for below version 2 use this

                isFloat
                    ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
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

  String isValidForm() {
    //checks if the entered values in the form are valid
    //returns appropriate error message if form is invalid
    //returns valid! if form is valid

    String errorMessage = "valid";

    if (_inputYarnCount.text.trim() == "") {
      errorMessage = "Input Yarn Count is Empty!";
      return errorMessage;
    } else {
      List range = settingsLimits["inputYarnCount"]!;
      double val = double.parse(_inputYarnCount.text.trim());
      if (val < range[0] || val > range[1]) {
        errorMessage = "Input Yarn Count values should be within $range";
        return errorMessage;
      }
    }

    if (_outputYarnDia.text.trim() == "") {
      return errorMessage;
    } else {
      List range = settingsLimits["outputYarnDia"]!;
      double val = double.parse(_outputYarnDia.text.trim());
      if (val < range[0] || val > range[1]) {
        errorMessage = "outputYarnDia values should be within $range";
        return errorMessage;
      }
    }



    if (_spindleSpeedChoice.trim() == "") {
      errorMessage = "Spindle Speed is Empty!";
      return errorMessage;
    } else {
      List range = settingsLimits["spindleSpeed"]!;
      double val = double.parse(_spindleSpeedChoice.trim());

      if (val < range[0] || val > range[1]) {
        errorMessage = "Spindle Speed values should be within $range";
        return errorMessage;
      }
    }

    if (_twistPerInch.text.trim() == "") {
      errorMessage = "Twist per Inch is Empty!";
      return errorMessage;
    } else {
      List range = settingsLimits["twistPerInch"]!;
      double val = double.parse(_twistPerInch.text.trim());

      if (val < range[0] || val > range[1]) {
        errorMessage = "Twist per Inch values should be within $range";
        return errorMessage;
      }
    }

    if (_packageHeight.text.trim() == "") {
      errorMessage = "Package Height is Empty!";
      return errorMessage;
    } else {
      List range = settingsLimits["packageHeight"]!;
      double val = double.parse(_packageHeight.text.trim());

      if (val < range[0] || val > range[1]) {
        errorMessage = "Package Height values should be within $range";
        return errorMessage;
      }
    }

    if (_diaBuildFactor.text.trim() == "") {
      errorMessage = "Dia Build Factor is Empty!";
      return errorMessage;
    } else {
      List range = settingsLimits["diaBuildFactor"]!;
      double val = double.parse(_diaBuildFactor.text.trim());

      if (val < range[0] || val > range[1]) {
        errorMessage = "Dia Build Factor values should be within $range";
        return errorMessage;
      }
    }

    if (_windingClosenessFactor.text.trim() == "") {
      errorMessage = "Winding Closeness Factor Height is Empty!";
      return errorMessage;
    } else {
      List range = settingsLimits["windingClosenessFactor"]!;
      double val = double.parse(_windingClosenessFactor.text.trim());

      if (val < range[0] || val > range[1]) {
        errorMessage =
            "Winding Closeness Factor values should be within $range";
        return errorMessage;
      }
    }

    if (_windingOffsetCoils.text.trim() == "") {
      errorMessage = "Winding Offset Coils is Empty!";
      return errorMessage;
    } else {
      List range = settingsLimits["windingOffsetCoils"]!;
      double val = double.parse(_windingOffsetCoils.text.trim());

      if (val < range[0] || val > range[1]) {
        errorMessage = "Winding Offset Coils values should be within $range";
        return errorMessage;
      }
    }

    return errorMessage;
  }

  void _requestSettings() async {
    try {
      connection!.output.add(
          Uint8List.fromList(utf8.encode(RequestSettings().createPacket())));

      await connection!.output!.allSent;
      await Future.delayed(Duration(seconds: 1)); //wait for acknowlegement
      /*SnackBar _sb = SnackBarService(
          message: "Sent Request for Settings!", color: Colors.green)
          .snackBar();*/
      //ScaffoldMessenger.of(context).showSnackBar(_sb);

      if (newDataReceived) {
        String _d = _data.last; //remember to make newDataReceived = false;

        Map<String, double> settings = RequestSettings().decode(_d);
        //settings = RequestSettings().decode(_d);

        if (settings.isEmpty) {
          throw const FormatException("Settings Returned Empty");
        }

        _inputYarnCount.text = settings["inputYarn"]!.toInt().toString();
        _outputYarnDia.text = settings["outputYarnDia"]!.toString();
        _spindleSpeedChoice = settings["spindleSpeed"]!.toInt().toString();
        _twistPerInch.text = settings["twistPerInch"]!.toInt().toString();
        _packageHeight.text = settings["packageHeight"]!.toInt().toString();
        _diaBuildFactor.text = settings["diaBuildFactor"].toString();
        _windingClosenessFactor.text = settings["windingClosenessFactor"]!.toInt().toString();
        _windingOffsetCoils.text = settings["windingOffsetCoils"]!.toInt().toString();

        newDataReceived = false;

        SettingsMessage _sm = SettingsMessage(
            inputYarn: _inputYarnCount.text,
            outputYarnDia: _outputYarnDia.text,
            spindleSpeed: _spindleSpeedChoice,
            twistPerInch: _twistPerInch.text,
            packageHt: _packageHeight.text,
            diaBuildFactor: _diaBuildFactor.text,
            windingClosenessFactor: _windingClosenessFactor.text,
            windingOffsetCoils: _windingOffsetCoils.text,
        );

        //update
        _outputYarnDia.text = _sm.outputYarnDia??"";

        RingDoublerConnectionProvider().setSettings(_sm.toMap());

        Provider.of<RingDoublerConnectionProvider>(context, listen: false).setSettings(_sm.toMap());

        SnackBar _sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(_sb);

        setState(() {});
      } else {
        SnackBar _sb = SnackBarService(message: "Settings Not Received", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(_sb);
      }
    } catch (e) {
      print("Settings!: ${e.toString()}");
      //Remember to change this error suppression
      if (e.toString() != "Bad state: Stream has already been listened to.") {
        SnackBar sb = SnackBarService(message: "Error in Receiving Settings", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sb);
      } else {
        SnackBar sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sb);
        setState(() {});
      }
    }
  }

  String calculate() {
    String errorMessage = "valid";
    //calculates rpm
    //always run this function in try catch
    double frCircumference = 94.248;
    double frRollerToMotorGearRatio = 4.61;

    /*
    var maxRPM = 1450;
    var strokeDistLimit = 5.5;

    var flyerMotorRPM = double.parse(_inputYarnCount.text) * 1.476;
    var deliveryMtrMin = (double.parse(_inputYarnCount.text)/ double.parse(_twistPerInch.text)) * 0.0254;

    double frRpm = (deliveryMtrMin * 1000) / frCircumference;
    var frMotorRpm = (frRpm * frRollerToMotorGearRatio);
    var brMotorRpm = ((frRpm * 23.562) / (double.parse(_spindleSpeedChoice)/ 1.5));

    double layerNo = 0; //layer 0 has highest speed for bobbin RPM so calculate only for that
    var bobbinDia = double.parse(_bareBobbinDia.text)+ layerNo * double.parse(_deltaBobbinDia.text);

    var deltaRpmSpindleBobbin = (deliveryMtrMin * 1000) /(bobbinDia * 3.14159);
    var bobbinRPM = double.parse(_inputYarnCount.text) + deltaRpmSpindleBobbin;
    var bobbinMotorRPM = bobbinRPM * 1.476;

    var strokeHeight = double.parse(_windingClosenessFactor.text) - ((double.parse(_rovingWidth.text) * double.parse(_coneAngleFactor.text)) * layerNo);
    var strokeDistPerSec = (deltaRpmSpindleBobbin * (double.parse(_rovingWidth.text) * double.parse(_coneAngleFactor.text))) / 60.0; //5.5
    var liftMotorRPM = (strokeDistPerSec * 60.0 / 4) * 15.3;

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
    if(liftMotorRPM> maxRPM){
      errorMessage = "Stroke Speed (${liftMotorRPM.toInt()}) exceeds  motor Max RPM ($maxRPM). Check 'Parameters' page for more details.";
      return errorMessage;
    }*/

    return errorMessage;
  }

  Container _checkConnection() {
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
            Text(
              "Please Reconnect...",
              style: TextStyle(
                  color: Theme.of(context).highlightColor, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomException implements Exception {
  String message;

  CustomException(this.message);

  @override
  String toString() {
    // TODO: implement toString
    return message;
  }
}
