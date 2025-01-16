
import 'package:flyer/message/hexa_to_double.dart';
import 'enums.dart';
import 'machineEnums.dart';


Map<String,List> settingsLimits = {
  "deliverySpeed":[2.5,50],
  "cardFeedRatio":[3,10],
  "cylSpeed":[300,750],
  "btrSpeed":[300,650],
  "pickerCylSpeed":[300,650],
  "btrFeed":[1,11],
  "lengthLimit":[100,1000],
  "afFeed":[1,8],
};
Map<String,List> pidSettingsLimits = {
  "Kp":[0,2000],
  "Ki":[0,2000],
  "FF":[0,80],
  "SO":[0,200],
};

class SettingsMessage{
  
  String deliverySpeed;
  String cardFeedRatio;
  String lengthLimit;
  String cylSpeed;
  String btrSpeed;
  String pickerCylSpeed;
  String btrFeed;
  String afFeed;


  SettingsMessage({
  required this.deliverySpeed,
  required this.cardFeedRatio,
  required this.lengthLimit,
  required this.cylSpeed,
  required this.btrSpeed,
  required this.pickerCylSpeed,
  required this.btrFeed,
  required this.afFeed,
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
    packet += attribute(SettingsAttribute.cardFeedRatio.hexVal, bit8s, padding(cardFeedRatio, bit8));
    packet += attribute(SettingsAttribute.lengthLimit.hexVal, bit4s, padding(lengthLimit, bit4));
    packet += attribute(SettingsAttribute.cylSpeed.hexVal, bit4s, padding(cylSpeed, bit4));
    packet += attribute(SettingsAttribute.btrSpeed.hexVal, bit4s, padding(btrSpeed, bit4));
    packet += attribute(SettingsAttribute.pickerCylSpeed.hexVal, bit4s, padding(pickerCylSpeed, bit4));
    packet += attribute(SettingsAttribute.btrFeed.hexVal, bit4s, padding(btrFeed, bit4));
    packet += attribute(SettingsAttribute.afFeed.hexVal, bit4s, padding(afFeed, bit4));

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
      "cardFeedRatio": cardFeedRatio,
      "cylSpeed": cylSpeed,
      "btrSpeed": btrSpeed,
      "pickerCylSpeed": pickerCylSpeed,
      "btrFeed": btrFeed,
      "lengthLimit": lengthLimit,
      "afFeed": afFeed,
    };

    return _settings;
  }

}


void main(){

  String s ="123456";

  print(SettingsAttribute.values.length.toString());
}