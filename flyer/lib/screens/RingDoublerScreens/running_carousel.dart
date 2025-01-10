import 'dart:convert';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/RingDoubler/carouselMessage.dart';
import 'package:flyer/message/RingDoubler/machineEnums.dart';

class RingDoublerRunningCarousel extends StatefulWidget {

  BluetoothConnection connection;
  Stream<Uint8List> multistream;

  RingDoublerRunningCarousel({required this.connection, required this.multistream});

  @override
  _RingDoublerRunningCarouselState createState() => _RingDoublerRunningCarouselState();
}

class _RingDoublerRunningCarouselState extends State<RingDoublerRunningCarousel> {

  List<int> items = [1,2,3,4];

  int index=0;
  
  List<String> _names = ["PRODUCTION","CALENDER","LIFT LEFT","LIFT RIGHT"];

  List<String> _ids = [
    "0A",//production hard coded
    MotorId.calender.hexVal,
    MotorId.liftLeft.hexVal,
    MotorId.liftRight.hexVal,
  ];

  String? motorTemp,MOSFETTemp,current,RPM,production,totalPower;

  late Stream<Uint8List> _stream;
  late BluetoothConnection _connection;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //send data to start receiving


    _stream = widget.multistream;
    _connection = widget.connection;


    //send initial carousel message

    String _productionID = "0A";

    String _m = CarouselMessage(carouselId: _productionID).createPacket();

    Future.delayed(Duration(milliseconds: 250)).then((value) => null);

    widget.connection.output.add(Uint8List.fromList(utf8.encode(_m)));

    widget.connection.output!.allSent.then((value) => null);

    Future.delayed(Duration(milliseconds: 250)).then((value) => null);

  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height*0.28,
        autoPlay: false,
        scrollDirection: Axis.horizontal,
        viewportFraction: 0.9,
        onPageChanged: (int idx,b) async {
          print(idx);
          onSlide(idx);
        }
      ),
      items: items.map((i) {

        return StreamBuilder<Uint8List>(
            stream: _stream,
            builder: (context, snapshot) {

              try{
                if(snapshot.hasData){

                  var data = snapshot.data;
                  String _d = utf8.decode(data!);
                  //print ("in Loop $i");
                  //print("\nRun PacketData: data: "+_d);

                  String _carousalID = _ids[i-1];

                  //print("carousal input No = $_carousalID");
                  Map<String,String> _carouselResponse = CarouselMessage(carouselId: _carousalID).decode(_d);
                  //print("HERE!!!!!!!!!!!!!!: $_carouselResponse");

                  if(!_carouselResponse.isEmpty) {
                    if (_carousalID == "0A") {
                      //for production
                      production = double.parse(_carouselResponse["outputMtrs"]!).toStringAsFixed(2);
                      totalPower = double.parse(_carouselResponse["totalPower"]!).toStringAsFixed(2);
                      //print ("after Carousal Response :$production , $totalPower");
                    }
                    else {
                      motorTemp = double.parse(_carouselResponse["motorTemp"]!).toStringAsFixed(0);
                      MOSFETTemp = double.parse(_carouselResponse["MOSFETTemp"]!).toStringAsFixed(0);
                      current = double.parse(_carouselResponse["current"]!).toStringAsFixed(2);
                      RPM = double.parse(_carouselResponse["RPM"]!).toStringAsFixed(0);

                    }
                  }

                  return Container(
                    margin: EdgeInsets.only(left: 2.5,right: 2.5),
                    width: MediaQuery.of(context).size.width*0.9,

                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[Colors.blue,Colors.blueAccent,Colors.lightBlue]
                      ),
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Text(_names[i-1], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),

                        i!=1? _customRow("Motor Temp (C)", motorTemp??"-"): _customRow("meters/Spindle", production??"-"),
                        i!=1? _customRow("MOSFET Temp (C)", MOSFETTemp??"-"): _customRow("Total Power (W)", totalPower??"-"),
                        i!=1?_customRow("Current (A)", current??"-"): Container(),
                        i!=1? _customRow("RPM", RPM??"-"): Container(),


                        DotsIndicator(
                          decorator: DotsDecorator(
                            color: Colors.white,
                            activeColor: Theme.of(context).primaryColor,
                          ),
                          dotsCount: items.length,
                          position: i.toDouble()-1,
                        ),
                      ],
                    ),
                  );
                }
                else{

                  return Container(
                    margin: EdgeInsets.only(left: 2.5,right: 2.5),
                    width: MediaQuery.of(context).size.width*0.9,

                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[Colors.blue,Colors.blueAccent,Colors.lightBlue]
                      ),
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [

                        Text(_names[i-1], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),

                        SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.5,
                          ),
                        ),

                        Text("Waiting For Data...", style: TextStyle(color: Colors.white, fontSize: 10),),

                        DotsIndicator(
                          decorator: DotsDecorator(
                            color: Colors.white,
                            activeColor: Theme.of(context).primaryColor,
                          ),
                          dotsCount: items.length,
                          position: i.toDouble()-1,
                        ),
                      ],
                    ),
                  );
                }
              }
              catch(e){
                print("carousel: ${e.toString()}");
                return Container(
                  margin: EdgeInsets.only(left: 2.5,right: 2.5),
                  width: MediaQuery.of(context).size.width*0.9,

                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[Colors.blue,Colors.blueAccent,Colors.lightBlue]
                    ),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [

                      Text(_names[i-1], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),

                      SizedBox(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1.5,
                        ),
                      ),

                      Text("Waiting For Data...", style: TextStyle(color: Colors.white, fontSize: 10),),

                      DotsIndicator(
                        decorator: DotsDecorator(
                          color: Colors.white,
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        dotsCount: items.length,
                        position: i.toDouble()-1,
                      ),
                    ],
                  ),
                );
              }
            }
        );

      }).toList(),
    );
  }

  Widget _customRow(String label, String val){

    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width*0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Text(label , style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
          Text(val, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,)),
        ],
      ),
    );
  }

  void onSlide(int idx) async{

    //send data
    String _id = _ids[idx];

    String _m = CarouselMessage(carouselId: _id).createPacket();

    await Future.delayed(Duration(milliseconds: 250));

    _connection!.output.add(Uint8List.fromList(utf8.encode(_m)));

    await _connection!.output!.allSent;

    await Future.delayed(Duration(milliseconds: 250));
  }
}
