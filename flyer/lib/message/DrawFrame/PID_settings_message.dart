import 'package:flyer/message/hexa_to_double.dart';
import 'enums.dart';
import 'machineEnums.dart';

class PidSettings{

  String motorName;
  String kP;
  String kI;
  String feedForward;
  String startOffset;

  String sof = Separator.sof.hexVal;
  String eof = Separator.eof.hexVal;

  PidSettings({
    required this.motorName,
    required this.kP,
    required this.kI,
    required this.feedForward,
    required this.startOffset
  });

  String getMotorHexFromName(String motorName) {
    switch (motorName) {
      case "FRONT ROLLER":
        return MotorId.frontRoller.hexVal;
        break;
      case "BACK ROLLER":
        return MotorId.backRoller.hexVal;
      case "CREEL":
        return MotorId.creel.hexVal;
      default:
        return MotorId.frontRoller.hexVal;
    }
  }

  String findPidParameterName(String t){
    if(t==pidParameters.kP.hexVal){
      return pidParameters.kP.name;
    }
    else if(t==pidParameters.kI.hexVal){
      return pidParameters.kI.name;
    }
    else if(t==pidParameters.feedForward.hexVal){
      return pidParameters.feedForward.name;
    }
    else if(t==pidParameters.startOffset.hexVal){
      return pidParameters.startOffset.name;
    }
    else{
      return "";
    }
  }


  String createTLV(String type, String length,String value){
    return type+length+value;
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


  //Functions
  String createRequestPacket(){

    String packet = "";
    String packetLength = "0E";
    String information = Information.pidRequest.hexVal;
    String subState = "00";
    String attributeCount = "01";
    String value = getMotorHexFromName(motorName);
    String tlvString  = createTLV("01","02",value);

    packet = sof+packetLength+information+subState+attributeCount+tlvString+eof;
    String out = packet.toUpperCase();
    return  out;
  }

  String createNewPidPacket(){
    String packet = "";
    String packetLength = "2E";//in hex
    String information = Information.pidNew.hexVal;
    String subState = "00";
    String attributeCount = "05";


    String motorHexVal = getMotorHexFromName(motorName);
    String motorString  = createTLV(pidParameters.whichMotor.hexVal,"02",padding(motorHexVal,2));
    String kPString  = createTLV(pidParameters.kP.hexVal,"04",padding(kP,4));
    String kIString  = createTLV(pidParameters.kI.hexVal,"04",padding(kI,4));
    String ffString  = createTLV(pidParameters.feedForward.hexVal,"04",padding(feedForward,4));
    String soString  = createTLV(pidParameters.startOffset.hexVal,"04",padding(startOffset,4));
    packet = sof+packetLength+information+subState+attributeCount+motorString+kPString+kIString+ffString+soString+eof;

    return  packet.toUpperCase();
  }

  Map<String, double> decodePacket(String packet) {
    //decodes packet after PID request is sent
    //print("packet: $packet");
    Map<String, double> pidSettings = Map<String, double>();

    String sof = packet.substring(0,2); //7E start of frame
    int len = int.parse(packet.substring(2,4),radix: 16); //Packet Length
    String info = packet.substring(4,6);

    int start = 10; //len("7EPL03AL")
    int end =  10+(len-8);

    if(sof!="7E"){
      throw const FormatException("Invalid Start Of Frame");
    }

    if(info!=Information.pidResponse.hexVal){
      throw const FormatException("Invalid Request Settings Code");
    }

    for(int i=start; i<end;){
      String t = packet.substring(i,i+2);
      int l = int.parse(packet.substring(i+2,i+4));
      String val = packet.substring(i+4,i+4+l);

      String key = findPidParameterName(t);
      double v; //int or double

      if(key == ""){
        throw const FormatException("Invalid Attribute Type");
      }
      if(l==4){
        v = int.parse(val,radix: 16).toDouble();
      }
      else{
        v = convert(val);
      }

      //print("t: $t, l: $l, v: $val");
      pidSettings[key] = v;
      i=i+4+l;
    }
    //print(pidSettings);
    return pidSettings;
  }

}



void main(){
  PidSettings p = PidSettings(motorName: "BACK ROLLER",kP: "23",kI: "10",feedForward: "40",startOffset: "3");
 // print(p.createRequestPacket());
 print(p.createNewPidPacket());

  //String settingsPacket = "7E280E0004010400010204000103040001040400017E";
  String settingsPacket = "7E280E0004010400230204001203040046040400007E";
 // print(p.decodePacket(settingsPacket));
}
