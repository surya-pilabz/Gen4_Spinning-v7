import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/im_paired.dart';
import 'package:flyer/screens/CardingScreens/Dashboard.dart';
import 'package:flyer/screens/DrawFrameScreens/Dashboard.dart';
import 'package:flyer/screens/FlyerScreens/Dashboard.dart';
import 'package:flyer/screens/RingDoublerScreens/Dashboard.dart';
import 'package:flyer/services/snackbar_service.dart';


import 'bluetoothFiles/SelectBondedDevicePage.dart';
import 'package:flyer/globals.dart' as globals;


class BluetoothPage extends StatefulWidget {

  String machineRoute;
  BluetoothPage({required this.machineRoute});



  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

 // BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
   // _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(title: const Text('General',style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),)),
            SwitchListTile(
              title: const Text('Enable Bluetooth', style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.w400),),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
              activeColor: Colors.lightGreen,
              inactiveThumbColor: Colors.blue,
            ),
            Divider(),
            ListTile(title: const Text('Device Settings', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),)),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                /*
                Container(
                  height: MediaQuery.of(context).size.height*0.05,
                  width: MediaQuery.of(context).size.width*0.9,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Colors.blue,Colors.lightGreen]
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {


                        final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return DiscoveryPage();
                            },
                          ),
                        );

                        if (selectedDevice != null) {
                          print('Discovery -> selected ' + selectedDevice.address);

                          globals.isConnected = true;

                          ConnectionProvider().setConnection(true);

                          globals.selectedDevice = selectedDevice;
                          BluetoothConnection connection = await BluetoothConnection.toAddress(selectedDevice.address);

                          //impaired message
                          connection!.output!.add(ascii.encode(ImPaired().createPacket()));
                          connection!.output.allSent;

                          Provider.of<ConnectionProvider>(context,listen: false).setConnection(true);

                          SnackBar _sb = SnackBarService(message: "Connected!", color: Colors.green).snackBar();

                          await ScaffoldMessenger.of(context).showSnackBar(_sb);

                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context){
                                return DashboardScaffold(connection: connection);
                              })
                          );

                        } else {
                          print('Discovery -> no device selected');

                          SnackBar _sb = SnackBarService(message: "No Device Selected!", color: Colors.red).snackBar();

                          ScaffoldMessenger.of(context).showSnackBar(_sb);
                        }

                      },
                      child: const Text('Discover Devices')
                  ),

                ),

                 */

                Container(
                  height: MediaQuery.of(context).size.height*0.05,
                  width: MediaQuery.of(context).size.width*0.9,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Colors.blue,Colors.lightGreen]
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    child: const Text('Paired Devices'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {

                      final BluetoothDevice? selectedDevice =
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return SelectBondedDevicePage(checkAvailability: false);
                          },
                        ),
                      );

                      if (selectedDevice != null) {

                        try {
                          print('Connect -> selected ' + selectedDevice.address);
                          globals.isConnected = true;
                          globals.selectedDevice = selectedDevice;
                          BluetoothConnection connection = await BluetoothConnection.toAddress(selectedDevice.address);

                          //im paired message
                          connection!.output!.add(ascii.encode(ImPaired().createPacket()));
                          await connection!.output.allSent;


                          SnackBar _sb = SnackBarService(message: "Connected!", color: Colors.green).snackBar();

                          await ScaffoldMessenger.of(context).showSnackBar(_sb);

                          _navigateToDashboard(connection);

                        }
                        catch(e){

                          print("Error pairing: paired devices: "+e.toString());
                          globals.isConnected = false;

                          //SnackBar _sb = SnackBarService(message: "Error Pairing", color: Colors.red).snackBar();

                          //ScaffoldMessenger.of(context).showSnackBar(_sb);
                        }
                      } else {
                        print('Connect -> no device selected');

                        SnackBar _sb = SnackBarService(message: "No Device Selected!", color: Colors.red).snackBar();

                        ScaffoldMessenger.of(context).showSnackBar(_sb);
                      }


                    },
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );

  }

  void _navigateToDashboard(BluetoothConnection connection){

    if(widget.machineRoute=="flyer"){

      Navigator.of(context).push(
          MaterialPageRoute(builder: (context){
            return FlyerDashboardScaffold(connection: connection);
          })
      );

    }
    if(widget.machineRoute=="carding"){

      Navigator.of(context).push(
          MaterialPageRoute(builder: (context){
            return CardingDashboardScaffold(connection: connection);
          })
      );
    }
    if(widget.machineRoute=="ringdoubler"){

      Navigator.of(context).push(
          MaterialPageRoute(builder: (context){
            return RingDoublerDashboardScaffold(connection: connection);
          })
      );
    }
    if(widget.machineRoute=="drawframe"){

      Navigator.of(context).push(
          MaterialPageRoute(builder: (context){
            return DrawFrameDashboardScaffold(connection: connection);
          })
      );
    }
  }


  AppBar _appBar(){

    return AppBar(
      title: const Text("Bluetooth"),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      shadowColor: Theme.of(context).highlightColor,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.blue,Colors.lightGreen]),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: (){
          print("from bluetooth to slect machine");
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
