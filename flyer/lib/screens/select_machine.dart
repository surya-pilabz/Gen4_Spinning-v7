import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyer/screens/bluetoothPage.dart';

class SelectMachineUI extends StatefulWidget {
  const SelectMachineUI({Key? key}) : super(key: key);

  @override
  _SelectMachineUIState createState() => _SelectMachineUIState();
}

class _SelectMachineUIState extends State<SelectMachineUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: _selectMachineUI(),
      ),
    );
  }

  Widget _selectMachineUI(){

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.08),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          _customTile("Carding","carding"),
          _customTile("Draw Frame","drawframe"),
          _customTile("Flyer Frame","flyer"),
          _customTile("Ring Doubler","ringdoubler"),
        ],

      ),
    );

  }

  Widget _customTile(String machineName, String route){

    return Container(
      width: MediaQuery.of(context).size.width*0.60,
      height: MediaQuery.of(context).size.height*0.10,
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),

      child: MaterialButton(

        child: Container(
          padding: EdgeInsets.all(1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(

              ),
              Text(machineName, style: TextStyle(fontSize: 22, color: Theme.of(context).highlightColor),),
              Icon(
                Icons.navigate_next,
                size: 25,
                color: Theme.of(context).highlightColor,
              ),
            ],
          ),
        ),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onPressed: (){
          //go to bluetooth page

          Navigator.of(context).push(
              MaterialPageRoute(builder: (context){
                return BluetoothPage(machineRoute: route);
              })
          );
        },
      )
    );
  }

  AppBar _appBar(){

    return AppBar(
      title: const Text("Select Machine"),
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
          print("exit");
          SystemNavigator.pop();
        },
      ),
    );
  }
}
