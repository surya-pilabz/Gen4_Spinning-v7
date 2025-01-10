
import 'package:flyer/message/hexa_to_double.dart';

import 'enums.dart';
import 'machineEnums.dart';

Map<String,List> settingsLimits = {
  "spindleSpeed":[500,1000],
  "draft":[5,15],
  "twistPerInch":[1,1.6],
  "RTF":[0.5,1.5],
  "layers":[1,100],
  "maxHeightOfContent":[250,300],
  "rovingWidth":[1,4],
  "deltaBobbinDia":[0.5,2.5],
  "bareBobbinDia":[46,52],
  "rampupTime":[5,20],
  "rampdownTime":[5,20],
  "changeLayerTime": [200,2500],
  "coneAngleFactor":[0.1,3],
};

class SettingsMessage{
  
  String spindleSpeed;
  String draft;
  String twistPerInch;
  String RTF;
  String layers;
  String maxHeightOfContent;
  String rovingWidth;
  String deltaBobbinDia;
  String bareBobbinDia;
  String rampupTime;
  String rampdownTime;
  String changeLayerTime;
  String coneAngleFactor;
  
  SettingsMessage({
  required this.spindleSpeed,
  required this.draft,
  required this.twistPerInch,
  required this.RTF,
  required this.layers,
  required this.maxHeightOfContent,
  required this.rovingWidth,
  required this.deltaBobbinDia,
  required this.bareBobbinDia,
  required this.rampupTime,
  required this.rampdownTime,
  required this.changeLayerTime,
  required this.coneAngleFactor
  });

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

    packet += attribute(SettingsAttribute.spindleSpeed.hexVal,bit4s,padding(spindleSpeed, bit4));
    packet += attribute(SettingsAttribute.draft.hexVal, bit8s, padding(draft, bit8));
    packet += attribute(SettingsAttribute.twistPerInch.hexVal, bit8s, padding(twistPerInch, bit8));
    packet += attribute(SettingsAttribute.RTF.hexVal, bit8s, padding(RTF, bit8));
    packet += attribute(SettingsAttribute.layers.hexVal,bit4s, padding(layers, bit4));
    packet += attribute(SettingsAttribute.maxHeightOfContent.hexVal, bit4s, padding(maxHeightOfContent, bit4));
    packet += attribute(SettingsAttribute.rovingWidth.hexVal, bit8s, padding(rovingWidth, bit8));
    packet += attribute(SettingsAttribute.deltaBobbinDia.hexVal, bit8s, padding(deltaBobbinDia,bit8));
    packet += attribute(SettingsAttribute.bareBobbinDia.hexVal, bit4s, padding(bareBobbinDia, bit4));
    packet += attribute(SettingsAttribute.rampupTime.hexVal, bit4s, padding(rampupTime, bit4));
    packet += attribute(SettingsAttribute.rampdownTime.hexVal, bit4s, padding(rampdownTime, bit4));
    packet += attribute(SettingsAttribute.changeLayerTime.hexVal, bit4s, padding(changeLayerTime, bit4));
    packet += attribute(SettingsAttribute.coneAngleFactor.hexVal, bit8s, padding(coneAngleFactor, bit8));

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
      "spindleSpeed": spindleSpeed,
      "draft": draft,
      "twistPerInch": twistPerInch,
      "RTF": RTF,
      "layers": layers,
      "maxHeightOfContent": maxHeightOfContent,
      "rovingWidth": rovingWidth,
      "deltaBobbinDia": deltaBobbinDia,
      "bareBobbinDia": bareBobbinDia,
      "rampupTime": rampupTime,
      "rampdownTime": rampdownTime,
      "changeLayerTime": changeLayerTime,
      "coneAngleFactor": coneAngleFactor,
    };

    return _settings;
  }
}


void main(){

  String s ="12345678";

  print(SettingsAttribute.values.length.toString());
}