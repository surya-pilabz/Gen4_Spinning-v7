
import 'dart:math';

import 'package:flyer/message/hexa_to_double.dart';

import 'machineEnums.dart';
import 'enums.dart';

Map<String,List> settingsLimits = {
  "inputYarnCount":[10,80],
  "outputYarnDia": [0.05,1.5],
  "spindleSpeed":[6000,12000],
  "twistPerInch":[12,30],
  "packageHeight":[50,250],
  "diaBuildFactor":[0.05,2.5],
  "windingClosenessFactor":[50,200],
  "windingOffsetCoils":[1,5],
};

class SettingsMessage{

  String inputYarn;
  String spindleSpeed;
  String? outputYarnDia;
  String twistPerInch;
  String packageHt;
  String diaBuildFactor;
  String windingClosenessFactor;
  String windingOffsetCoils;

  SettingsMessage({
    required this.inputYarn,
    required this.spindleSpeed,
    required this.twistPerInch,
    required this.packageHt,
    required this.diaBuildFactor,
    required this.windingClosenessFactor,
    required this.windingOffsetCoils,
    this.outputYarnDia,
  }){

    if(outputYarnDia==null || outputYarnDia?.trim()==""){
      outputYarnDia = (-0.10284 + 1.592/sqrt(double.parse(inputYarn)/2)).toStringAsFixed(2);
    }
  }

  String createPacket(){

    String packet = "";

    String packetLength = "";
    String attributeCount =  SettingsAttribute.values.length.toString();

    int bit4 = 4; //for padding
    String bit4s = "04";

    int bit8 = 8;
    String bit8s = "08";

    int bit2 = 2;
    String bit2s = "02";


    //  packet += packetLength;
    
    packet += Information.settingsFromApp.hexVal;
    packet += Substate.running.hexVal; // doesnt matter for this usecase
    packet += padding(attributeCount,bit2);

    packet += attribute(SettingsAttribute.inputYarn.hexVal,bit4s,padding(inputYarn, bit4));
    packet += attribute(SettingsAttribute.outputYarnDia.hexVal, bit8s, padding(outputYarnDia??"", bit8));
    packet += attribute(SettingsAttribute.spindleSpeed.hexVal,bit4s,padding(spindleSpeed, bit4));
    packet += attribute(SettingsAttribute.twistPerInch.hexVal, bit4s, padding(twistPerInch, bit4));
    packet += attribute(SettingsAttribute.packageHeight.hexVal, bit4s, padding(packageHt, bit4));
    packet += attribute(SettingsAttribute.diaBuildFactor.hexVal,bit8s, padding(diaBuildFactor, bit8));
    packet += attribute(SettingsAttribute.windingClosenessFactor.hexVal, bit4s, padding(windingClosenessFactor, bit4));
    packet += attribute(SettingsAttribute.windingOffsetCoils.hexVal, bit4s, padding(windingOffsetCoils, bit4));

    packet += Separator.eof.hexVal;

    packetLength = padding(packet.length.toString(),2);

    packet = Separator.sof.hexVal + packetLength + packet;

    print(packet);
    return packet.toUpperCase();
  }

  String attribute(String attributeType, String attributeLength,String attributeValue){

    return attributeType+attributeLength+attributeValue;
  }

  String padding(String str,int no){

    //pad with 4

    String s;
    int len;

    if(no==4 || no == 2){

      s = double.parse(str).toInt().toString();
      s = int.parse(s).toRadixString(16);
      len = s.length;
    }
    else{
      //no==8 means its a floating point
      
      s = hexConvert(double.parse(str));
      len = s.length;
    }


    for(int i = 0;i < no-len;i++){
      s = "0"+s;
    }

    return s;
  }

  Map<String,String> toMap(){

    Map<String,String> _settings = {
      "inputYarnCount": inputYarn,
      "outputYarnDia": outputYarnDia??"",
      "spindleSpeed": spindleSpeed,
      "twistPerInch": twistPerInch,
      "packageHeight": packageHt,
      "diaBuildFactor": diaBuildFactor,
      "windingClosenessFactor":windingClosenessFactor,
      "windingOffsetCoils": windingOffsetCoils,
    };

    return _settings;
  }
}


void main(){

  String s ="12345678";

  print(SettingsAttribute.values.length.toString());
}