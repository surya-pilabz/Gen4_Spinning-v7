import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/DrawFrame/provider_service.dart';

class DrawFramePopUpUI extends StatefulWidget {
  const DrawFramePopUpUI({Key? key}) : super(key: key);

  @override
  _DrawFramePopUpUIState createState() => _DrawFramePopUpUIState();
}

class _DrawFramePopUpUIState extends State<DrawFramePopUpUI> {

  late double frMotorRPM;
  late double brMotorRPM;

  late double frRpm;
  late double brRpm;
  
  late double req_br_surfaceSpeed;
  late double _deliverySpeed;
  late double _draft;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(!Provider.of<DrawFrameConnectionProvider>(context,listen: false).isSettingsEmpty){

      Map<String,String> _s = Provider.of<DrawFrameConnectionProvider>(context,listen: false).settings;

      _deliverySpeed = double.parse(_s["deliverySpeed"].toString());
      _draft =  double.parse(_s["draft"].toString());

    }

  }
  @override
  Widget build(BuildContext context) {

    if(Provider.of<DrawFrameConnectionProvider>(context,listen: false).isSettingsEmpty){

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Empty',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
        ],
      );
    }
    else{

      try{
        calculate();
      }
      catch(e){
        print("pop up ui:  ${e.toString()}");
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Empty',
                style:
                TextStyle(color: Colors.black, fontSize:  15),
              ),
            ),
          ],
        );
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Internal Parameters',
              style:
              TextStyle(color: Colors.black, fontSize:  18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Delivery Speed :\t${_deliverySpeed??"-"} m/min',
              style:
              const TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Draft:\t\t${_draft.toStringAsFixed(2)??"-"}',
              style:
              const TextStyle(
                  color: Colors.black,
                  fontSize:  15,
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Front Roller RPM:\t\t${frRpm.ceil()??"-"}',
              style:
              const TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Back Roller RPM:\t\t${brRpm.ceil()??"-"}',
              style:
              const TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Front Roller Motor RPM:\t\t\t\t${frMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: frMotorRPM <= 1450?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Back Roller Motor RPM:    ${brMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: brMotorRPM <= 1450?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),
        ],
      );
    }


  }

  
  void calculate(){

    double deliveryspdMmin= _deliverySpeed;
    double draft= _draft;

    double frCircumference = 125.6;
    double brCircumference = 94.2;

    frRpm = deliveryspdMmin * 1000/frCircumference;
    frMotorRPM = frRpm * 1;
    req_br_surfaceSpeed = deliveryspdMmin*1000/draft;
    brRpm = req_br_surfaceSpeed/brCircumference;
    brMotorRPM = brRpm * 6.91;

  }


}

