import 'package:flyer/message/hexa_to_double.dart';

import 'enums.dart';
import 'machineEnums.dart';

class CarouselMessage{

  String carouselId;

  CarouselMessage({
    required this.carouselId,
  });

  Map<String, String> decode(String packet) {

    //decodes packet for carousel


    Map<String, String> _settings = Map<String, String>();

    String sof = packet.substring(0,2); //7E start of frame

    int len = int.parse(packet.substring(2,4),radix: 16); //Packet Length


    String _machineState = packet.substring(4,6);
    String _ss = packet.substring(6,8);

    int _attributeLength = int.parse(packet.substring(8,10)); //should be 3

    //print(_attributeLength);

    int start = 10; //len("7EPL03AL")
    int end = start + len-8;

    if(sof!="7E"){

      print("Carousel Message: Invalid Start Of Frame");
      return Map<String, String>();
      //throw FormatException("Carousel Message: Invalid Start Of Frame");
    }

    String _ssn = substateName(_ss);

    if(_ssn != ""){

    }
    else{
      print("Carousel Message: Invalid Substate");
      return Map<String, String>();
      //throw FormatException("Carousel Message: Invalid Substate");
    }

    if(_machineState!=Information.machineState.hexVal){
      print("Carousel Message: Invalid Request Settings Code");
      return Map<String, String>();
      //throw FormatException("Carousel Message: Invalid Request Settings Code");

    }


    for(int i=start; i<end;){

      String t = packet.substring(i,i+2);

      int l = int.parse(packet.substring(i+2,i+4));

      String val = packet.substring(i+4,i+4+l);

      String key = attributeName(t);

      double v; //int or double

      if(key == ""){
        print("carousel message: Invalid Attribute Type");
        return Map<String, String>();
        //throw FormatException("Invalid Attribute Type");
      }

      //print ("Key:$key,Len:$l,Val:$val");

      if(l==4 || l==2){
        v = int.parse(val,radix: 16).toDouble();
      }
      else{
        v = convert(val);
      }

      if(key==Running.whatInfo.name){
        //print("whatInfo V parameter = $val");
        //print("carousal No = $carouselId");
        if(val.padLeft(2,"0") != carouselId){
          //print("Carousel Info What Info and Motor ID don't match");
          return Map<String, String>();
          //throw FormatException("Carousel Info What Info and Motor ID don't match");
        }
      }
      //print("t: $t, l: $l, v: $val key: $key");
      if (key == Running.whatInfo.name){
        _settings[key] = val;
      }else {
        _settings[key] = v.toString();
      }

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

    return "";
  }

  String attributeName(String t){

    //chooses attribute based on substate


    if(t==Running.whatInfo.hexVal){
      //ensure what info value matches the motor id
      return Running.whatInfo.name;
    }
    else if(t==Running.currentLength.hexVal){
      return Running.currentLength.name;
    }
    else if(t==Running.motorTemp.hexVal){
      return Running.motorTemp.name;
    }
    else if(t==Running.MOSFETTemp.hexVal){
      return Running.MOSFETTemp.name;
    }
    else if(t==Running.current.hexVal){
      return Running.current.name;
    }
    else if(t==Running.RPM.hexVal){
      return Running.RPM.name;
    }
    else if(t==Running.outputMtrs.hexVal){
      return Running.outputMtrs.name;
    }
    else if(t==Running.totalPower.hexVal){
      return Running.totalPower.name;
    }
    else{
      return "";
    }
  }

  String createPacket(){

    String _packet = Separator.sof.hexVal+"08"+Information.carouselInfo.hexVal+carouselId+"00"+Separator.eof.hexVal;

    return _packet;
  }
}