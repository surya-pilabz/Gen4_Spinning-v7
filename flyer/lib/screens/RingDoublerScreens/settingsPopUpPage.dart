import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/RingDoubler/provider_service.dart';

class RDPopUpUI extends StatefulWidget {
  const RDPopUpUI({Key? key}) : super(key: key);

  @override
  _RDPopUpUIState createState() => _RDPopUpUIState();
}

class _RDPopUpUIState extends State<RDPopUpUI> {

  late double delivery_mtr_min;
  late double calMotorRPM;
  late double outputCountInNm;
  late double windingVelocity;
  late double bindingVelocity;
  late double windingTimeSec;
  late double bindingTimeSec;
  late double bindingliftMotorRPM;

  late double htDifferencePerStroke;
  late double strokesPerDoff;
  late double maxStrokesPerZ;
  late double estFullBobbinWidth;

  late double doffTime;
  late double totalYarnLength;
  late double totalyarnWeightInGrams;

  late double _inputYarnCount;
  late double _outputYarnDia ;
  late double _twistPerInch ;
  late double _spindleSpeed;
  late double _packageHeight ;
  late double _diaBuildFactor ;
  late double _windingClosenessFactor ;
  late double _windingOffsetCoils ;

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(!Provider.of<RingDoublerConnectionProvider>(context,listen: false).isSettingsEmpty){

      Map<String,String> _s = Provider.of<RingDoublerConnectionProvider>(context,listen: false).settings;

      _inputYarnCount = double.parse(_s["inputYarnCount"].toString());
      _outputYarnDia =  double.parse(_s["outputYarnDia"].toString());
      _twistPerInch = double.parse(_s["twistPerInch"].toString());
      _spindleSpeed = double.parse(_s["spindleSpeed"]!);
      _packageHeight = double.parse(_s["packageHeight"].toString());
      _diaBuildFactor=double.parse(_s["diaBuildFactor"].toString());
      _windingClosenessFactor  = double.parse(_s["windingClosenessFactor"].toString());
      _windingOffsetCoils = double.parse(_s["windingOffsetCoils"].toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    if(Provider.of<RingDoublerConnectionProvider>(context,listen: false).isSettingsEmpty){

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
              'Delivery:\t${delivery_mtr_min.toStringAsFixed(2)??"-"} m/min',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Calendar Motor RPM:\t${calMotorRPM.toStringAsFixed(1)??"-"} ',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Output Yarn Count in Nm:\t${outputCountInNm.toStringAsFixed(2)??"-"}',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Winding Velocity:\t\t${windingVelocity.toStringAsFixed(2)??"-"} mm/s',
              style:
              TextStyle(
                  color: Colors.black,
                  fontSize:  15,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Binding Velocity:\t\t${bindingVelocity.toStringAsFixed(2)??"-"} mm/s',
              style:
              TextStyle(
                color: Colors.black,
                fontSize:  15,
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Winding Time :\t\t${windingTimeSec.toStringAsFixed(1)??""} sec',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Binding Time :\t\t${bindingTimeSec.toStringAsFixed(1)??""} sec',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Lift Motor RPM during Binding :\t\t${bindingliftMotorRPM.ceil()??""}',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'HtDifferencePerStroke:\t\t\t\t${htDifferencePerStroke.toStringAsFixed(2)??""} mm',
              style:
              TextStyle(
                  color: Colors.black,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'StrokesPerDoff :\t\t\t\t ${strokesPerDoff.ceil()??"-"}',
              style:
              TextStyle(
                  color: Colors.black,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'MaxStrokesPerZ:    ${maxStrokesPerZ.ceil()??"-"}',
              style:
              TextStyle(
                  color: Colors.black,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Estimated Full Bobbin Width:    ${estFullBobbinWidth.toStringAsFixed(2)??"-"}',
              style:
              TextStyle(
                  color: Colors.black,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Doff Time:    ${doffTime.toStringAsFixed(2)??""} min',
              style:
              TextStyle(
                  color: Colors.black,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Total Yarn Length:    ${totalYarnLength.toStringAsFixed(2)??"-"} mtrs',
              style:
              TextStyle(
                  color: Colors.black,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Total Yarn Weight in Grams:    ${totalyarnWeightInGrams.toStringAsFixed(2)??"-"} grams',
              style:
              TextStyle(
                  color:Colors.black,
                  fontSize:  15
              ),
            ),
          ),
        ],
      );
    }


  }

  
  void calculate(){

    delivery_mtr_min = (_spindleSpeed/ _twistPerInch) * 0.0254;
    var calRollerCircumference = 141.37;
    var calRollerRPM = delivery_mtr_min*1000/calRollerCircumference;
    var calRollerGB = 6.91;
    calMotorRPM = calRollerRPM * calRollerGB;


    outputCountInNm = (_inputYarnCount /2)/0.591;
    var emptyBobbinDiaMM = 24;
    var emptyBobbinWidth_Circ = emptyBobbinDiaMM * pi;
    var windingVelocity_mmMin = ((delivery_mtr_min*1000.0)/emptyBobbinWidth_Circ) * _outputYarnDia * (_windingClosenessFactor/100.0);

    windingVelocity = windingVelocity_mmMin/60.0;
    bindingVelocity = windingVelocity*2;

    var chaselength = 55;
    windingTimeSec = chaselength/windingVelocity;
    bindingTimeSec = chaselength/bindingVelocity;

    var leadscrewPitch = 4;
    var turns_min = windingVelocity_mmMin/leadscrewPitch;
    var liftGB_Ratio = 24;
    var windingLiftMotorRPM = turns_min*liftGB_Ratio;
    bindingliftMotorRPM = windingLiftMotorRPM* 2;

    htDifferencePerStroke = _windingOffsetCoils*(_windingClosenessFactor/100.0)*_outputYarnDia/_diaBuildFactor;
    strokesPerDoff = (_packageHeight - chaselength)/htDifferencePerStroke;
    maxStrokesPerZ = chaselength/htDifferencePerStroke;
    estFullBobbinWidth = maxStrokesPerZ * (_outputYarnDia * 2) + emptyBobbinDiaMM;

    var timePerStroke = (windingTimeSec + bindingTimeSec)/60.0;
    doffTime = strokesPerDoff * timePerStroke;
    totalYarnLength = doffTime * delivery_mtr_min;
    totalyarnWeightInGrams = totalYarnLength/outputCountInNm ;
  }


}

