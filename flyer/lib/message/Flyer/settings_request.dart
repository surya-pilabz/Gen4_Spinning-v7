
import 'package:flyer/message/hexa_to_double.dart';

import 'enums.dart';
import 'machineEnums.dart';

class RequestSettings{

  Map<String, double> decode(String packet) {
    //decodes packet after settings request is sent

    //print("packet: $packet");

    Map<String, double> _settings = Map<String, double>();

    String sof = packet.substring(0,2); //7E start of frame
    int len = int.parse(packet.substring(2,4),radix: 16); //Packet Length

    String _requestSettings = packet.substring(4,6);
    String _ss = packet.substring(6,8); //not necessary

    int _attributeLength = int.parse(packet.substring(8,10));
    print(_attributeLength);

    int start = 10; //len("7EPL03AL")
    int end = start + len-8;

    if(sof!="7E"){
      throw FormatException("Invalid Start Of Frame");
    }


    if(_requestSettings!="02"){
      print(packet);

      throw FormatException("Invalid Request Settings Code");
    }

    for(int i=start; i<end;){

      String t = packet.substring(i,i+2);


      int l = int.parse(packet.substring(i+2,i+4));

      String val = packet.substring(i+4,i+4+l);

      String key = attributeName(t);

      double v; //int or double

      if(key == ""){
        throw FormatException("Invalid Attribute Type");
      }
      
      if(l==4){
        v = int.parse(val,radix: 16).toDouble();
      }
      else{
        v = convert(val);
      }

     // print("t: $t, l: $l, v: $val. key: $key");
      _settings[key] = v;

      i=i+4+l;
    }
   // print(_settings);
    return _settings;
  }

  String createPacket(){

    String packet = "";
    String packetLength = "08";
    String attributeLength = "00";

    packet = Separator.sof.hexVal+packetLength+Information.requestSettings.hexVal+Substate.idle.hexVal+attributeLength+Separator.eof.hexVal;

    return packet;
  }

  String attributeName(String t){

    if(t==SettingsAttribute.spindleSpeed.hexVal){
      return SettingsAttribute.spindleSpeed.name;
    }
    else if(t==SettingsAttribute.draft.hexVal){
      return SettingsAttribute.draft.name;
    }
    else if(t==SettingsAttribute.draft.hexVal){
      return SettingsAttribute.draft.name;
    }
    else if(t==SettingsAttribute.twistPerInch.hexVal){
      return SettingsAttribute.twistPerInch.name;
    }
    else if(t==SettingsAttribute.RTF.hexVal){
      return SettingsAttribute.RTF.name;
    }
    else if(t==SettingsAttribute.layers.hexVal){
      return SettingsAttribute.layers.name;
    }
    else if(t==SettingsAttribute.maxHeightOfContent.hexVal){
      return SettingsAttribute.maxHeightOfContent.name;
    }
    else if(t==SettingsAttribute.rovingWidth.hexVal){
      return SettingsAttribute.rovingWidth.name;
    }
    else if(t==SettingsAttribute.deltaBobbinDia.hexVal){
      return SettingsAttribute.deltaBobbinDia.name;
    }
    else if(t==SettingsAttribute.bareBobbinDia.hexVal){
      return SettingsAttribute.bareBobbinDia.name;
    }
    else if(t==SettingsAttribute.rampupTime.hexVal){
      return SettingsAttribute.rampupTime.name;
    }
    else if(t==SettingsAttribute.rampdownTime.hexVal){
      return SettingsAttribute.rampdownTime.name;
    }
    else if(t==SettingsAttribute.changeLayerTime.hexVal){
      return SettingsAttribute.changeLayerTime.name;
    }
    else if(t==SettingsAttribute.coneAngleFactor.hexVal){
      return SettingsAttribute.coneAngleFactor.name;
    }
    else{
      return "";
    }
  }
}

void main() {

  String p = "7E840200125004028A51084100000052083F99999A540404B05504011856084040000057083F8000005804003053083F80000059042EE060041F4060041F40610403207E";
  
  print(RequestSettings().decode(p));
}

