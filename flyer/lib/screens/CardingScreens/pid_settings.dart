import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/services/Carding/provider_service.dart';
import 'package:provider/provider.dart';
import '../../message/Carding/CardingPID_Settings.dart';
import '../../message/Carding/enums.dart';
import '../../message/acknowledgement.dart';
import '../../services/snackbar_service.dart';
import '../../message/Carding/settingsMessage.dart';


class PIDSettingsCarding extends StatefulWidget {

  BluetoothConnection connection;
  Stream<Uint8List> settingsStream;
  PIDSettingsCarding({super.key, required this.connection, required this.settingsStream});

  @override
  _PIDSettingsCardingState createState() => _PIDSettingsCardingState();
}

class _PIDSettingsCardingState extends State<PIDSettingsCarding> {
  bool newDataReceived = false;
  List<String> _data = List<String>.empty(growable: true);
  final TextEditingController kP_ = TextEditingController();
  final TextEditingController kI_ = TextEditingController();
  final TextEditingController feedForward_ = TextEditingController();
  final TextEditingController startOffset_ = TextEditingController();

  final List<String> _motorName = ["CARD CYLINDER","BEATER CYLINDER","CAGE","CARDING FEED","BEATER FEED","COILER","PICKER CYLINDER","AF FEED"];
  late String selectedDropDownMotor = _motorName.first;
  late String previousDropDownMotor = _motorName.first;
  late PidSettings p0;
  late BluetoothConnection connection;
  late Stream<Uint8List> settingsStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    p0 = PidSettings(motorName: selectedDropDownMotor, kP: "0", kI: "0", feedForward: "0", startOffset: "0");
    try{
      connection = widget.connection;
      settingsStream = widget.settingsStream;
    }
    catch(e){
      print("Settings: Connection init: ${e.toString()}");
    }
    try{
      settingsStream.listen(_onDataReceived).onDone(() {});
    }
    catch(e){

      print("Settings: Listening init: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _enabled = true;  // You can modify this based on your provider state

    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.65),
                1: FractionColumnWidth(0.30),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                _customRowWithDropDown("Motor Name", _motorName),
                _customRow("Kp", kP_, isFloat: true, enabled: _enabled),
                _customRow("Ki", kI_, isFloat: true, enabled: _enabled),
                _customRow("Feed Forward", feedForward_, isFloat: false, enabled: _enabled),
                _customRow("Start Offset", startOffset_, isFloat: false, enabled: _enabled),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.input,
                  label: "Input",
                  onPressed: () => _requestPIDSettings(),
                ),
                _buildActionButton(
                  icon: Icons.save,
                  label: "Save",
                  onPressed: () => _savePIDSettings(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar(){

    return AppBar(
      title: const Text("PID Settings"),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      shadowColor: Theme.of(context).highlightColor,
      centerTitle: true,

      leading: IconButton(
        icon: const Icon(Icons.arrow_back,color: Colors.black,),
        onPressed: (){
          Navigator.of(context).pop();
        },
      ),

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.blue,Colors.lightGreen]),
        ),
      ),


    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Theme.of(context).primaryColor),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  TableRow _customRow(String label, TextEditingController controller,
      {bool isFloat = true, bool enabled = true}) {
    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(top: 12.5, bottom: 2.5),
            color: enabled ? Colors.transparent : Colors.grey.shade400,
            child: TextField(
              enabled: enabled,
              controller: controller,
              inputFormatters: <TextInputFormatter>[
                isFloat
                    ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                    : FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                FilteringTextInputFormatter.deny('-'),
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _customRowWithDropDown(String label, List<String> dropDownList) {
    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            child: DropdownButton<String>(
              value: selectedDropDownMotor,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              isExpanded: true,
              style: TextStyle(color: Theme.of(context).primaryColor),
              underline: Container(
                height: 2,
                color: Theme.of(context).primaryColor,
              ),
              onChanged: (String? value) {
                setState(() {
                  if (previousDropDownMotor != value) {
                    selectedDropDownMotor = value!;
                    _clearFields();
                    previousDropDownMotor = value;
                  }
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

  void _clearFields() {
    kP_.text = "";
    kI_.text = "";
    feedForward_.text = "";
    startOffset_.text = "";
  }

  void _requestPIDSettings()
    // TODO - Implement your PID settings request logic here
    async {
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
  void _savePIDSettings()
    // TODO - Implement your PID settings save logic here
    async {
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
          // CardingConnectionProvider().setSettings(_sm.toMap());
          // Provider.of<CardingConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

          connection.output.add(Uint8List.fromList(utf8.encode(_msg)));
          await connection.output.allSent;
          await Future.delayed(const Duration(seconds: 2)); //wait for acknowledgement

print(newDataReceived);
print(_data);
          if (newDataReceived) {
            String _d = _data.last;
print(_d+" "+Acknowledgement().createPacket());
            if (_d == Acknowledgement().createPacket()) {
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
          _d == Acknowledgement().createPacket() || _d == Acknowledgement().createPacket(error: true)){

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
}