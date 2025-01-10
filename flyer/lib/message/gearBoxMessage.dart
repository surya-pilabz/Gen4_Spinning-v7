import 'package:flyer/message/hexa_to_double.dart';

import 'Flyer/enums.dart';

class GearBoxMessage{

  Map<String, String> decode(String packet) {

    //decodes packet for gear box

    Map<String, String> _settings = Map<String, String>();

    String sof = packet.substring(0,2); //7E start of frame

    int len = int.parse(packet.substring(2,4),radix: 16); //Packet Length


    String _machineState = packet.substring(4,6);
    String _ss = packet.substring(6,8);

    int _attributeLength = int.parse(packet.substring(8,10)); //should be 2

    //print(_attributeLength);

    int start = 10; //len("7EPL03AL")
    int end = start + len-8;

    if(sof!="7E"){
      print("Status Message: Invalid Start Of Frame");
      return Map<String, String>();

      //throw FormatException("Status Message: Invalid Start Of Frame");
    }

    String _ssn = substateName(_ss);

    if(_ssn != ""){
      _settings["substate"] = _ssn;
    }
    else{
      print("Status Message: Invalid Substate");
      return Map<String, String>();
      //throw FormatException("Status Message: Invalid Substate");
    }


    if(_machineState!=Information.gearBoxSettingsFromMachine.hexVal){
      print("Status Message: Invalid Request Settings Code");
      return Map<String, String>();

      //throw FormatException("Status Message: Invalid Request Settings Code");
    }


    for(int i=start; i<end;){

      String t = packet.substring(i,i+2);


      int l = int.parse(packet.substring(i+2,i+4));

      String val = packet.substring(i+4,i+4+l);

      String key = attributeName(t);

      double v; //int or double

      if(key == ""){
        i=i+4+l;
        continue;
        //throw FormatException("Invalid Attribute Type");
      }

      if(l==4){
        v = int.parse(val,radix: 16).toDouble();
      }
      else{
        v = convert(val);
      }



      //print("t: $t, l: $l, v: $val");
      _settings[key] = v.toString();

      i=i+4+l;
    }



    print(_settings);
    return _settings;
  }

  String substateName(String t){

    List<Substate> vals = Substate.values;

    for(int i=0; i<vals.length;i++){

      Substate v = vals[i];

      if(v.hexVal == t){
        return v.name;
      }
    }

    return "0";
  }

  String attributeName(String t){

    //chooses attribute based on substate


    if(t==GearBoxSettings.start.hexVal){
      return GearBoxSettings.start.name;
    }
    else if(t==GearBoxSettings.stop.hexVal){
      return GearBoxSettings.stop.name;
    }
    else if(t== GearBoxSettings.saveRight.hexVal){
      return GearBoxSettings.saveRight.name;
    }
    else if(t == GearBoxSettings.saveLeft.hexVal){
      return GearBoxSettings.saveLeft.name;
    }
    else{
      return "";
    }
  }

  String start(){

    String packet = "";

    packet = Separator.sof.hexVal+"08"+Information.gearBoxSettingsFromApp.hexVal+GearBoxSettings.start.hexVal+"00"+Separator.eof.hexVal;

    return packet;
  }

  String stop(){

    String packet = "";

    packet = Separator.sof.hexVal+"08"+Information.gearBoxSettingsFromApp.hexVal+GearBoxSettings.stop.hexVal+"00"+Separator.eof.hexVal;

    return packet;
  }

  String left(){

    String packet = "";

    packet = Separator.sof.hexVal+"08"+Information.gearBoxSettingsFromApp.hexVal+GearBoxSettings.saveLeft.hexVal+"00"+Separator.eof.hexVal;

    return packet;
  }

  String right(){

    String packet = "";

    packet = Separator.sof.hexVal+"08"+Information.gearBoxSettingsFromApp.hexVal+GearBoxSettings.saveRight.hexVal+"00"+Separator.eof.hexVal;

    return packet;
  }
}