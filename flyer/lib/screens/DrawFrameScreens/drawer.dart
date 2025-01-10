
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/changeName.dart';
import 'package:flyer/screens/bluetoothPage.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:flyer/globals.dart' as globals;
import 'package:flyer/services/DrawFrame/provider_service.dart';
import 'package:provider/provider.dart';

import '../../services/snackbar_service.dart';

class DrawFrameDrawerPage extends StatefulWidget {

  BluetoothConnection connection;
  Stream<Uint8List> stream;

  DrawFrameDrawerPage({required this.connection, required this.stream});


  @override
  _DrawFrameDrawerPageState createState() => _DrawFrameDrawerPageState();
}

class _DrawFrameDrawerPageState extends State<DrawFrameDrawerPage> {

  late String _deviceName;

  bool _validate = true;
  String _validText = "";

  late TextEditingController _deviceNameController;

  late BluetoothConnection connection;
  late Stream<Uint8List> stream;

  @override
  void initState() {
    // TODO: implement initState

    _deviceName = "";
    _deviceNameController = new TextEditingController();

    connection = widget.connection;
    stream = widget.stream;
    super.initState();
  }




  void _exitApp(){
    print("exit");
    SystemNavigator.pop();
  }

  void _changeDeviceName(){

    print("change name");

    _displayChangeName();
  }


  @override
  Widget build(BuildContext context) {
    return  Drawer(
      child: Container(
        height: MediaQuery.of(context).size.height,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.08,
            ),

            MaterialButton(

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Icon(Icons.bluetooth,color: Colors.grey[400],),
                  Container(
                    width: 30,
                  ),
                  Text("Change Device Name",style: TextStyle(fontWeight: FontWeight.w400,color: Theme.of(context).primaryColor),)
                ],
              ),
              onPressed: () {
                _changeDeviceName();
              },
            ),
            Divider(),
            MaterialButton(

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Icon(Icons.exit_to_app,color: Colors.grey[400],),
                  Container(
                    width: 30,
                  ),
                  Text("Exit App",style: TextStyle(fontWeight: FontWeight.w400,color: Theme.of(context).primaryColor),)
                ],
              ),
              onPressed: () {
                _exitApp();
              },
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _displayChangeName() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Change Name of Device:'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  _deviceName = value;
                });
              },
              controller: _deviceNameController,
              decoration: InputDecoration(
                  hintText: "Enter New Device Name",
                  labelText: 'Enter the Value',
                  errorText: validateName(_deviceNameController.text),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                ),
                child: Text('OK'),
                onPressed: () async {

                    if(_deviceNameController.text=="" || _deviceNameController.text==" " || _deviceNameController.text.length > 8){


                        setState(() {

                        });
                    }
                    else{

                      try {
                        String _cnm = ChangeName().changeName(_deviceName);

                        connection!.output.add(Uint8List.fromList(utf8.encode(_cnm)));

                        await connection!.output!.allSent;

                        await Future.delayed(Duration(milliseconds: 100));

                        stream.listen((data) async {

                          String _d = utf8.decode(data);

                          if(_d==null || _d==""){

                            print("Drawer: Change name: Invalid Packet");
                            await showMessage("Failed To Change Name");

                            throw FormatException("Failed To Change Name");
                          }

                          if(_d == Acknowledgement().createErrorPacket()){
                            Navigator.of(context).pop();
                            await showMessage("Changed Name Successfully");

                          }
                          else{
                            await showMessage("Failed To Change Name");
                            throw FormatException("Failed To Change Name");
                          }
                        }).onError((e){
                          print(e.toString());
                        });



                      }
                      catch(e){
                        print("Change Name: ${e.toString()}");

                        await showMessage(e.toString());
                      }


                    }

                },
              ),

            ],
          );
        });
  }

  String? validateName(String s){

    if(s.length > 8){

      return "Invalid Name";

    }
    else{
      return null;
    }
  }

  Future<void> showMessage(String message){

    return showDialog(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height*0.25,
            width: MediaQuery.of(context).size.width*0.8,
            child: AlertDialog(
              title: Text('Change Name of Device:'),
              content: Text(
                  message,
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                  ),
                  child: Text('OK'),
                  onPressed: ()  {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
    });

  }

  String getHashedPassword(String p){
    var bytes = utf8.encode(p); // data being hashed

    var digest = sha1.convert(bytes);

    return digest.toString();
  }
}

