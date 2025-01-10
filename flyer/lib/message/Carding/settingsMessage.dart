
import 'package:flyer/message/hexa_to_double.dart';
import 'enums.dart';
import 'machineEnums.dart';


Map<String,List> settingsLimits = {
  "deliverySpeed":[2.5,50],
  "draft":[0.5,4],
  "cylSpeed":[300,750],
  "btrSpeed":[300,650],
  "cylFeedSpeed":[0.1,11],
  "btrFeedSpeed":[0.1,11],
  "trunkDelay":[1,10],
  "lengthLimit":[30,300],
  "rampTimes":[3,10],
};

class SettingsMessage{
  
  String deliverySpeed;
  String draft;
  String cylSpeed;
  String beaterSpeed;
  String cylFeedSpeed;
  String btrFeedSpeed;
  String trunkDelay;
  String lengthLimit;
  String rampTimes;

  SettingsMessage({
  required this.deliverySpeed,
  required this.draft,
  required this.cylSpeed,
  required this.beaterSpeed,
  required this.cylFeedSpeed,
  required this.btrFeedSpeed,
  required this.trunkDelay,
  required this.lengthLimit,
  required this.rampTimes,
  });

  String createPacket(SettingsUpdate substate){

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
    packet += substate.hexVal;
    packet += padding(attributeCount,bit2);

    packet += attribute(SettingsAttribute.deliverySpeed.hexVal,bit8s,padding(deliverySpeed, bit8));
    packet += attribute(SettingsAttribute.draft.hexVal, bit8s, padding(draft, bit8));
    packet += attribute(SettingsAttribute.cylSpeed.hexVal, bit4s, padding(cylSpeed, bit4));
    packet += attribute(SettingsAttribute.btrSpeed.hexVal, bit4s, padding(beaterSpeed, bit4));
    packet += attribute(SettingsAttribute.cylFeedSpeed.hexVal, bit8s, padding(cylFeedSpeed, bit8));
    packet += attribute(SettingsAttribute.btrFeedSpeed.hexVal, bit8s, padding(btrFeedSpeed, bit8));
    packet += attribute(SettingsAttribute.trunkDelay.hexVal, bit4s, padding(trunkDelay, bit4));
    packet += attribute(SettingsAttribute.lengthLimit.hexVal, bit4s, padding(lengthLimit, bit4));
    packet += attribute(SettingsAttribute.rampTimes.hexVal, bit4s, padding(rampTimes, bit4));

    packet += Separator.eof.hexVal;

    packetLength = padding(packet.length.toString(),2);

    packet = Separator.sof.hexVal + packetLength + packet;
    //print(packet);
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
      "cylSpeed": cylSpeed,
      "btrSpeed": beaterSpeed,
      "cylFeedSpeed": cylFeedSpeed,
      "btrFeedSpeed": btrFeedSpeed,
      "trunkDelay": trunkDelay,
      "lengthLimit": lengthLimit,
      "rampTimes": rampTimes,
    };

    return _settings;
  }
}


void main(){

  String s ="12345678";

  print(SettingsAttribute.values.length.toString());
}