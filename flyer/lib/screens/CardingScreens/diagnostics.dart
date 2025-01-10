import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/Carding/diagnosticMessage.dart';

import 'package:flyer/globals.dart' as globals;
import 'package:flyer/services/snackbar_service.dart';
import 'package:provider/provider.dart';

import '../../services/Carding/provider_service.dart';


class CardingTestPage extends StatefulWidget {

  BluetoothConnection connection;

  Stream<Uint8List> testsStream;


  CardingTestPage({required this.connection, required this.testsStream});


  @override
  _CardingTestPageState createState() => _CardingTestPageState();
}

class _CardingTestPageState extends State<CardingTestPage> {

  //run diagnose variables
  List<String> _motorName = ["CARD CYLINDER","BEATER CYLINDER","CAGE","CARDING FEED","BEATER FEED","COILER"];
  List<String> _controlType = ["OPEN LOOP","CLOSED LOOP"];

  List<String> _motorDirection = ["DEFAULT","REVERSE"];

  List<String> _liftMotors = ["BOTH","LEFT","RIGHT"];
  List<String> _bedDirection = ["UP","DOWN"];

  //bedTravelDistance : 2-250 mm

  late String _testTypeChoice = "MOTOR"; //HARDCODED TO MOTOR
  late String _motorNameChoice = _motorName.first;
  late String _controlTypeChoice = _controlType.first;

  late String _motorDirectionChoice = _motorDirection.first;

  late double _target = 10; //10-90%
 // final TextEditingController _targetRPM = new TextEditingController();
  late String _testRuntime = "20";
  late double _testRuntimeval = 20;

  final TextEditingController _bedTravelDistance = new TextEditingController();

  String _targetRPM="150";
  String _dutyPerc="10";
  String prev="0";


  late BluetoothConnection connection;
  late Stream<Uint8List> testsStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try{
      connection = widget.connection;
      testsStream = widget.testsStream;
    }
    catch(e){
      print("TESTS: Connection init: ${e.toString()}");
    }

  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    if(connection.isConnected){
      return Container(
        padding: EdgeInsets.only(left: 10,top: 7,bottom: 7, right: 7),
        //scrollDirection: Axis.vertical,
        child: _runDiagnoseUI(),
      );
    }
    else{
      return _checkConnection();
    }

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

  Widget _runDiagnoseUI(){
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(MediaQuery.of(context).size.height*0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 15),
            child: Center(
              child: Text(
                "Tests",
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
              0: FractionColumnWidth(0.50),
              1: FractionColumnWidth(0.50),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children:  <TableRow>[
              //Motor Name section
              TableRow(
                children: <Widget>[

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Motor Name",
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
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: DropdownButton<String>(
                        value: _motorNameChoice,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        alignment: FractionalOffset.topLeft,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(),
                        isExpanded: true,
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _motorNameChoice = value!;
                          });
                        },
                        items: _motorName.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              ),

              // this is the control Type section.
              TableRow(
                children: <Widget>[
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Control Type",
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
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: DropdownButton<String>(
                        value: _controlTypeChoice,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(),
                        isExpanded: true,
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _controlTypeChoice = value!;
                          });
                        },
                        items: _controlType.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              ),

              //This section is for motor direction
              TableRow(
                children: <Widget>[
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Motor Direction",
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
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: DropdownButton<String>(
                        value: _motorDirectionChoice,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(),
                        isExpanded: true,
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _motorDirectionChoice = value!;
                          });
                        },
                        items: _motorDirection.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              ),

              // this is target% section. If "MOTOR", then put a target Row, a specialized table row,
              //else an empty rable row
              _targetRow("Target(%)"),

              //if "MOTOR", is open Loop put target Duty, if Closed loop put targetRPM
              _controlTypeChoice!="OPEN LOOP" ?
                  TableRow(
                    children: <Widget>[
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            "Target RPM",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child:
                        Container(
                          margin: EdgeInsets.only(top:10,left: 5, right: 5,bottom: 10),
                          child: Text(
                            _targetRPM,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),

                    ],
                  ) //closedLoop
                  :TableRow(    //openLoop
                  children: <Widget>[
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          "Duty Percent",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child:
                      Container(
                        margin: EdgeInsets.only(top:10,left: 5, right: 5,bottom: 10),
                        child: Text(
                          _dutyPerc,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ]
              ),

              //Run Time
              _testTimeRow("Run Time (%)"),

              //if "MOTOR", is open Loop put target Duty, if Closed loop put targetRPM
              TableRow(
                children: <Widget>[
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "RunTime Seconds",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                    Container(
                      margin: EdgeInsets.only(top:10,left: 5, right: 5,bottom: 10),
                      child: Text(
                        _testRuntime,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),

          Provider.of<CardingConnectionProvider>(context,listen: false).settingsChangeAllowed ?
          Container(
            height: MediaQuery.of(context).size.height*0.05,
            width: MediaQuery.of(context).size.width*0.9,
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
                onPressed: runDiagnose,
                child: Text("RUN DIAGNOSE",style: TextStyle(fontWeight: FontWeight.bold),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),

              ),
            ),
          )
          :Container(),

        ],
      ),
    );
  }

  String getTargetRPM(String _target){

    double perc = 0;
    double num = 1500;

    if(_target != null || _target != ""){

      try {
        perc = double.parse(_target);
      }
      catch(e){
        perc = 0;
      }

      if(perc > 100){
        perc = 100;
      }

      if(perc < 0){
        perc = 0;
      }
    }

    perc = (perc * num)/100;

    return ((perc/10.0).ceil()*10).toString();

  }



  TableRow _customRow2(String label, TextEditingController controller){

    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
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
            width: MediaQuery.of(context).size.width*0.2,
            margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
              ],
            ),
          ),
        ),

      ],
    );
  }




  TableRow _targetRow(String label){
    //slider row
    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            child: Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(right: 2.5),
            margin: EdgeInsets.only(right: 2.5),
            child: Slider(
              value: _target,
              max: 90.0,
              min: 10.0,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (val){
                setState(() {
                  _target = (val/5).ceil()*5;
                  _targetRPM = getTargetRPM(_target.toString());
                  _dutyPerc = ((val/5).ceil()*5).toString()+"%";
                });
              },
            ),
          ),
        ),

      ],
    );
  }

  TableRow _testTimeRow(String label){
    //slider row
    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            child: Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: EdgeInsets.only(right: 2.5),
            margin: EdgeInsets.only(right: 2.5),
            child: Slider(
              value: _testRuntimeval,
              max: 310.0,
              min: 20.0,
              activeColor: Theme.of(context).primaryColor,
              // label: _testRuntime.toString(),
              onChanged: (val){
                setState(() {
                  _testRuntimeval = (val/10).ceil()*10;
                  _testRuntime = _testRuntimeval.toInt().toString();
                  if(_testRuntimeval>300){
                    _testRuntime = "infinity";
                  }
                });
              },
            ),
          ),
        ),

      ],
    );
  }


  void runDiagnose() async {



    if(_bedTravelDistance!=null && _bedTravelDistance.text!="" && _bedTravelDistance.text!=" "){

      String val = _bedTravelDistance.text;

      if(double.parse(val) < globals.diagnosticLimits["bedTravelDistance"]![0] || double.parse(val) > globals.diagnosticLimits["bedTravelDistance"]![1]){
        SnackBar _sb = SnackBarService(message: "Bed Travel Distance Range ${globals.diagnosticLimits["bedTravelDistance"]}", color: Colors.red).snackBar();

        ScaffoldMessenger.of(context).showSnackBar(_sb);
        return;
      }


    }

    try {

      DiagnosticMessage _dm = DiagnosticMessage(
          testTypeChoice: _testTypeChoice,
          motorNameChoice: _motorNameChoice,
          controlTypeChoice: _controlTypeChoice,
          target: _target.toString(),
          targetRPM: _targetRPM,
          testRuntime: _testRuntimeval.toString(),
          motorDirection:  _motorDirectionChoice,
          bedDirectionChoice: "UP",
          bedTravelDistance: "1",
      );


      String _m = _dm.createPacket();

      print(_m);

      connection!.output.add(Uint8List.fromList(utf8.encode(_m)));

      await connection!.output!.allSent;
      //globals.connection!.close();

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_){

            if(_testTypeChoice=="MOTOR" && _motorNameChoice=="DRAFTING"){

              String leftTitle,rightTitle;

              leftTitle = "FR";
              rightTitle = "BR";

              return DrawFrameStopDiagnoseDoubleUI(
                connection: connection,
                testsStream: testsStream,
                isLift: false,
                leftTitle: leftTitle,
                rightTitle: rightTitle,
              );
            }
            else{
              return DrawFrameStopDiagnoseSingleUI(
                connection: connection,
                testsStream: testsStream,
                isLift: false,
              );
            }
          }
        ),
      );

    }
    catch(e){

      print("Tests2: ${e.toString()}");
    }

  }




}

class DrawFrameStopDiagnoseSingleUI extends StatefulWidget {

  BluetoothConnection? connection;
  Stream<Uint8List>? testsStream;
  bool isLift;


  DrawFrameStopDiagnoseSingleUI({required this.connection, required this.testsStream, required this.isLift});

  @override
  _DrawFrameStopDiagnoseSingleUIState createState() => _DrawFrameStopDiagnoseSingleUIState();
}

class _DrawFrameStopDiagnoseSingleUIState extends State<DrawFrameStopDiagnoseSingleUI> {

  String? _runningRPM;
  String? _runningSignalVoltage;
  String? _current;
  String? _power;

  String? _lift;

  bool isConnected = false;


  BluetoothConnection? connection;
  Stream<Uint8List>? testsStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    connection = widget.connection;
    testsStream = widget.testsStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Blow Card",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Container(),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.blue,Colors.lightGreen]),
          ),
        ),
      ),
      body: Container(

        padding: EdgeInsets.only(left: 10,top: 7,bottom: 7, right: 7),
        //scrollDirection: Axis.vertical,
        child: _stopDiagnoseUI(),
      ),

    );

  }

  Widget _stopDiagnoseUI(){
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,

      child: StreamBuilder<Uint8List>(
        stream: testsStream,
        builder: (context, snapshot) {

          if(snapshot.hasData){
            var data = snapshot.data;
            String _d = utf8.decode(data!);
            //print("\nTESTS: run diagnose data: "+_d);
            //print(snapshot.data);


            try{

              Map<String,double> _diagResponse = DiagnosticMessageResponse().decode(_d);
              //print("HERE!!!!!!!!!!!!!!: $_diagResponse");

              _runningRPM = _diagResponse["speedRPM"]!.toStringAsFixed(0);
              _runningSignalVoltage = _diagResponse["signalVoltage"]!.toStringAsFixed(0);
              _current = _diagResponse["current"]!.toStringAsFixed(2);
              _power = _diagResponse["power"]!.toStringAsFixed(2);

            }
            catch(e){
              print("error in DiagnosticsResponse: ${e.toString()}");
            }
          }


          return Column(

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.1,
                width: MediaQuery.of(context).size.width,

                child: Center(
                  child: Text("TEST RESULTS",style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20,color: Theme.of(context).primaryColor),),
                ),
              ),
              Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FractionColumnWidth(0.5),
                  1: FractionColumnWidth(0.5),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  _customRow("Speed (RPM)", _runningRPM),
                  _customRow("PWM (0 to 1500)", _runningSignalVoltage),
                  _customRow("Current (A)", _current),
                  _customRow("Power (W)", _power),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.05,
                width: MediaQuery.of(context).size.width*0.9,
                margin: const EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Colors.blue,Colors.lightGreen]
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: ElevatedButton(
                    onPressed: (){
                      _stopDiagnose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("STOP DIAGNOSE", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _stopDiagnose() async {

    try{
      setState(() {

        String _sd = StopDiagnostics().stopDiagnosePacket();

        connection!.output.add(Uint8List.fromList(utf8.encode(_sd)));

        testsStream = null;
        isConnected = false;

      });

      Navigator.of(context).pop();
    }
    catch(e){
      print("Tests3: ${e.toString()}");
    }
  }

  TableRow _customRow(String label,String? attribute){

    //attribute will change
    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
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
            width: MediaQuery.of(context).size.width*0.2,
            margin: const EdgeInsets.only(top: 2.5,bottom: 2.5),
            padding: const EdgeInsets.only(left: 5, top: 11),
            child: Text(attribute ?? "--", ),
          ),
        ),

      ],
    );
  }
}


class DrawFrameStopDiagnoseDoubleUI extends StatefulWidget {

  BluetoothConnection? connection;
  Stream<Uint8List>? testsStream;
  bool isLift;

  String leftTitle,rightTitle;


  DrawFrameStopDiagnoseDoubleUI({required this.connection, required this.testsStream, required this.isLift, required this.leftTitle, required this.rightTitle});

  @override
  _DrawFrameStopDiagnoseDoubleUIState createState() => _DrawFrameStopDiagnoseDoubleUIState();
}

class _DrawFrameStopDiagnoseDoubleUIState extends State<DrawFrameStopDiagnoseDoubleUI> {

  //call this UI when there are two motors

  String? _runningRPM1, _runningRPM2;
  String? _runningSignalVoltage1,_runningSignalVoltage2;
  String? _current1,_current2;
  String? _power1,_power2;
  bool isConnected = false;


  BluetoothConnection? connection;
  Stream<Uint8List>? testsStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    connection = widget.connection;
    testsStream = widget.testsStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Draw Frame",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Container(),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.blue,Colors.lightGreen]),
          ),
        ),
      ),
      body: Container(

        padding: EdgeInsets.only(left: 10,top: 7,bottom: 7, right: 7),
        //scrollDirection: Axis.vertical,
        child: _stopDiagnoseUI(),
      ),

    );

  }

  Widget _stopDiagnoseUI(){
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,

      child: StreamBuilder<Uint8List>(
        stream: testsStream,
        builder: (context, snapshot) {

          if(snapshot.hasData){
            var data = snapshot.data;
            String _d = utf8.decode(data!);
            print("\nTESTS: run diagnose data: "+_d);
            print(snapshot.data);


            try{

              Map<String,double> _diagResponse = DiagnosticMessageResponse().decode(_d);
              print("HERE!!!!!!!!!!!!!!: $_diagResponse");

              _runningRPM1 = _diagResponse["speedRPM"]!.toStringAsFixed(0);
              _runningSignalVoltage1 = _diagResponse["signalVoltage"]!.toStringAsFixed(0);
              _current1 = _diagResponse["current"]!.toStringAsFixed(2);
              _power1 = _diagResponse["power"]!.toStringAsFixed(2);

              _runningRPM2 = _diagResponse["speedRPM1"]!.toStringAsFixed(0);
              _runningSignalVoltage2 = _diagResponse["signalVoltage1"]!.toStringAsFixed(0);
              _current2 = _diagResponse["current1"]!.toStringAsFixed(2);
              _power2 = _diagResponse["power1"]!.toStringAsFixed(2);
            }
            catch(e){
              print("Diagnostics Reponse Err: ${e.toString()}");
            }
          }


          return Column(

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.1,
                width: MediaQuery.of(context).size.width,

                child: Center(
                  child: Text("TEST RESULTS",style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20,color: Theme.of(context).primaryColor),),
                ),
              ),
              Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FractionColumnWidth(0.4),
                  1: FractionColumnWidth(0.3),
                  2: FractionColumnWidth(0.3),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  _customRow("", widget.leftTitle, widget.rightTitle),
                  _customRow("Speed (RPM)", _runningRPM1, _runningRPM2),
                  _customRow("PWM ", _runningSignalVoltage1, _runningSignalVoltage2),
                  _customRow("Current (A)", _current1, _current2),
                  _customRow("Power (W)", _power1, _power2),

                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.05,
                width: MediaQuery.of(context).size.width*0.9,
                margin: EdgeInsets.only(top: 40),
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
                    onPressed: (){
                      _stopDiagnose();
                    },
                    child: Text("STOP DIAGNOSE", style: TextStyle(fontWeight: FontWeight.bold),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _stopDiagnose() async {

    try{
      setState(() {

        String _sd = StopDiagnostics().stopDiagnosePacket();

        connection!.output.add(Uint8List.fromList(utf8.encode(_sd)));

        testsStream = null;
        isConnected = false;

      });

      Navigator.of(context).pop();
    }
    catch(e){
      print("Tests3: ${e.toString()}");
    }
  }

  TableRow _customRow(String label,String? attribute, String? attribute2){

    //attribute will change
    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
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
            width: MediaQuery.of(context).size.width*0.2,
            margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
            padding: EdgeInsets.only(left: 5, top: 11),
            child: Text(attribute ?? "--", ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child:
          Container(

            height: MediaQuery.of(context).size.height*0.05,
            width: MediaQuery.of(context).size.width*0.2,
            margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
            padding: EdgeInsets.only(left: 5, top: 11),
            child: Text(attribute2 ?? "--", ),
          ),
        ),

      ],
    );
  }


}

