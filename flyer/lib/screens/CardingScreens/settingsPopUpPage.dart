import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/Carding/provider_service.dart';

class CardingPopUpUI extends StatefulWidget {
  const CardingPopUpUI({Key? key}) : super(key: key);

  @override
  CardingPopUpUIState createState() => CardingPopUpUIState();
}

class CardingPopUpUIState extends State<CardingPopUpUI> {

  late  double cylinderMotorRPM;
  late  double beaterMotorRPM;
  late  double cylinderFeedMotorRPM;
  late  double beaterFeedMotorRPM;
  late  double cageMotorRPM;
  late  double coilerMotorRPM;

  late double _deliverySpeed;
  late double _draft;
  late double _cylinderSpeed;
  late double _beaterSpeed;
  late double _cylFeedSpeed;
  late double _btrFeedSpeed;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(!Provider.of<CardingConnectionProvider>(context,listen: false).isSettingsEmpty){

      Map<String,String> _s = Provider.of<CardingConnectionProvider>(context,listen: false).settings;

      _deliverySpeed = double.parse(_s["deliverySpeed"].toString());
      _draft =  double.parse(_s["draft"].toString());
      _cylinderSpeed = double.parse(_s["cylSpeed"].toString());
      _beaterSpeed = double.parse(_s["btrSpeed"].toString());
      _cylFeedSpeed = double.parse(_s["cylFeedSpeed"].toString());
      _btrFeedSpeed = double.parse(_s["btrFeedSpeed"].toString());
    }

  }
  @override
  Widget build(BuildContext context) {

    if(Provider.of<CardingConnectionProvider>(context,listen: false).isSettingsEmpty){

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
              'Cylinder Motor RPM :\t${cylinderMotorRPM.toStringAsFixed(0)??"-"}',
              style:
              TextStyle(
                  color: cylinderMotorRPM <= 3500?  Colors.black: Colors.red,
                  fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Beater Motor RPM:\t\t${beaterMotorRPM.toStringAsFixed(0)??"-"}',
              style:
              TextStyle(
                  color: beaterMotorRPM <= 3500?  Colors.black: Colors.red,
                  fontSize:  15,
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Cylinder Feed Motor RPM:\t\t${cylinderFeedMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color:cylinderFeedMotorRPM <= 1450?  Colors.black: Colors.red,
                  fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Beater Feed Motor RPM:\t\t${beaterFeedMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: beaterFeedMotorRPM <= 1450?  Colors.black: Colors.red,
                  fontSize:  15),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Cage Motor RPM:\t\t\t\t${cageMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: cageMotorRPM <= 1450?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Coiler Motor RPM:    ${coilerMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: coilerMotorRPM <= 1450?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),
        ],
      );
    }


  }

  
  void calculate(){

    double deliverySpeed = _deliverySpeed;
    double draft = _draft;
    double cylSpeed = _cylinderSpeed;
    double btrSpeed = _beaterSpeed;
    double cylFeedSpeed = _cylFeedSpeed;
    double btrFeedSpeed = _btrFeedSpeed;

    double cylinderGearRatio = 4;
    double beaterGearRatio = 4;
    double cylinderFeedGb = 120;
    double beaterFeedGb = 120;
    double tongueGrooveCircumferenceMm = 213.63;
    double cageGb = 5;
    double coilerGrooveCircumferenceMm = 194.779;
    double coilerGrooveToGbRatio = 1.656;
    double coilerGb = 6.91;

    cylinderMotorRPM = cylSpeed*cylinderGearRatio;
    beaterMotorRPM = btrSpeed*beaterGearRatio;
    cylinderFeedMotorRPM = cylFeedSpeed * cylinderFeedGb;
    beaterFeedMotorRPM = btrFeedSpeed * beaterFeedGb;
    double cageGbRpm = (deliverySpeed*1000)/tongueGrooveCircumferenceMm;
    cageMotorRPM = cageGbRpm * cageGb;
    double reqCoilerTongueSurfaceSpeedMm = (deliverySpeed*1000) * draft;
    double reqCoilerTongueRpm = reqCoilerTongueSurfaceSpeedMm/coilerGrooveCircumferenceMm;
    double coilerGbRpm = reqCoilerTongueRpm/coilerGrooveToGbRatio;
    coilerMotorRPM = coilerGbRpm * coilerGb;
  }


}

