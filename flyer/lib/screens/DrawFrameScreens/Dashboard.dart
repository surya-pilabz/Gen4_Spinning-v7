
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/screens/DrawFrameScreens/diagnostics.dart';
import 'package:flyer/screens/FlyerScreens/drawer.dart';
import 'package:flyer/screens/DrawFrameScreens/advanced_options.dart';
import 'package:flyer/screens/DrawFrameScreens/phone_status_page.dart';
import 'package:flyer/screens/DrawFrameScreens/settings.dart';
import 'package:flyer/screens/FlyerScreens/diagnostics.dart';

import 'package:flyer/globals.dart' as globals;
import 'package:provider/provider.dart';
import '../../services/DrawFrame/provider_service.dart';
import '../../services/snackbar_service.dart';

class DrawFrameDashboardScaffold extends StatefulWidget {

  BluetoothConnection connection;

  DrawFrameDashboardScaffold({required this.connection});

  @override
  _DrawFrameDashboardScaffoldState createState() => _DrawFrameDashboardScaffoldState();
}

class _DrawFrameDashboardScaffoldState extends State<DrawFrameDashboardScaffold> {

  int _selectedIndex = 0;
  late BluetoothConnection connection;
  late Stream<Uint8List> multiStream; //for multiple stream

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState


    if(widget.connection.isConnected){
      //if connection is already established
      connection = widget.connection;

      setState(() {});
    }
    else{
      //reconnect with the selected device's address
      BluetoothConnection.toAddress(globals.selectedDevice!.address).then((_connection) {
        print('Connected to the device');

        connection = _connection;

        setState(() {

        });
      });
    }

    try{
      multiStream = connection!.input!.asBroadcastStream();
    }
    catch(e){
      print("Dashboard: Broadcast stream: ${e.toString()}");
    }


    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    widget.connection.finish();
    widget.connection.close();
    widget.connection.dispose();

    DrawFrameConnectionProvider().clearSettings();
    Provider.of<DrawFrameConnectionProvider>(context,listen: false).clearSettings();

    super.dispose();
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {

    if(connection.isConnected){
      final List<Widget> _pages = <Widget>[
        //checks if the device is a phone or tablet based on screen size
        //MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.shortestSide < 550 ?
        DrawFramePhoneStatusPageUI(connection: connection,statusStream: multiStream,),
        DrawFrameSettingsPage(connection: connection, settingsStream: multiStream,),
        DrawFrameTestPage(connection: connection, testsStream: multiStream,),
        DrawFrameAdvancedOptionsUI(connection: connection,stream: multiStream,),
      ];

      return Scaffold(
        key: _scaffoldKey,
        appBar: appBar(_scaffoldKey),
        bottomNavigationBar: navigationBar(),
        body: _pages[_selectedIndex],
      );
    }
    else{

      final List<Widget> _pages = <Widget>[
        //checks if the device is a phone or tablet based on screen size
        _checkConnection(),
        _checkConnection(),
        _checkConnection(),
        _checkConnection(),
      ];

      return Scaffold(
        key: _scaffoldKey,
        appBar: appBar(_scaffoldKey),
        bottomNavigationBar: navigationBar(),
        body: _pages[_selectedIndex],
      );
    }
  }

  AppBar appBar(GlobalKey<ScaffoldState> _scaffoldKey){

    return AppBar(
      title: const Text("Draw Frame"),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      shadowColor: Theme.of(context).highlightColor,
      centerTitle: true,

      leading: IconButton(
        icon: Icon(Icons.bluetooth,color: Colors.white,),
        onPressed: (){
          widget.connection.finish();
          widget.connection.close();
          widget.connection.dispose();

          DrawFrameConnectionProvider().clearSettings();
          Provider.of<DrawFrameConnectionProvider>(context,listen: false).clearSettings();

          SnackBar _sb = SnackBarService(message: "Pair Again", color: Colors.green).snackBar();

          ScaffoldMessenger.of(context).showSnackBar(_sb);

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




  BottomNavigationBar navigationBar(){
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart,color: Colors.grey,),label: "status"),
        BottomNavigationBarItem(icon: Icon(Icons.settings, color: Colors.grey,),label: "settings"),
        BottomNavigationBarItem(icon: Icon(Icons.build, color: Colors.grey,),label: "tests"),
        BottomNavigationBarItem(icon: Icon(Icons.engineering, color: Colors.grey,),label: "options"),
      ],
      selectedItemColor: Colors.lightGreen,
      onTap: _onItemTapped,
    );
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

