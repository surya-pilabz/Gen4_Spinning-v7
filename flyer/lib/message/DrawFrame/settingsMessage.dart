
import 'package:flyer/message/hexa_to_double.dart';
import 'enums.dart';
import 'machineEnums.dart';


Map<String,List> settingsLimits = {
  "deliverySpeed":[50,150],
  "draft":[5,12],
  "lengthLimit":[5,1250],
  "rampUpTime":[1,15],
  "rampDownTime":[1,15],
  "creelTensionFactor":[0.25,5],
};

Map<String,List> pidSettingsLimits = {
  "Kp":[0,2000],
  "Ki":[0,2000],
  "FF":[0,80],
  "SO":[0,200],
};

class SettingsMessage{
  
  String deliverySpeed;
  String draft;
  String lengthLimit;
  String rampUpTime;
  String rampDownTime;
  String creelTensionFactor;

  SettingsMessage({
  required this.deliverySpeed,
  required this.draft,
  required this.lengthLimit,
  required this.rampUpTime,
  required this.rampDownTime,
  required this.creelTensionFactor,
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

    packet += attribute(SettingsAttribute.deliverySpeed.hexVal,bit4s,padding(deliverySpeed, bit4));
    packet += attribute(SettingsAttribute.draft.hexVal, bit8s, padding(draft, bit8));
    packet += attribute(SettingsAttribute.lengthLimit.hexVal, bit4s, padding(lengthLimit, bit4));
    packet += attribute(SettingsAttribute.rampUpTime.hexVal, bit4s, padding(rampUpTime, bit4));
    packet += attribute(SettingsAttribute.rampDownTime.hexVal,bit4s, padding(rampDownTime, bit4));
    packet += attribute(SettingsAttribute.creelTensionFactor.hexVal,bit8s, padding(creelTensionFactor, bit8));

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
      "deliverySpeed": deliverySpeed,
      "draft": draft,
      "lengthLimit": lengthLimit,
      "rampUpTime": rampUpTime,
      "rampDownTime": rampDownTime,
      "creelTensionFactor": creelTensionFactor,
    };

    return _settings;
  }
}


void main(){

  String s ="12345678";

  print(SettingsAttribute.values.length.toString());
}