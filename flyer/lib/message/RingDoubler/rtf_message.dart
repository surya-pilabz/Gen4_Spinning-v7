import 'enums.dart';
import '../hexa_to_double.dart';


class RTFMessage{

  String value;

  RTFMessage({required this.value});

  String createPacket(){

    String packet = "";

    String packetLength = "";
    String attributeCount =  "01";

    int bit4 = 4; //for padding
    String bit4s = "04";

    int bit8 = 8;
    String bit8s = "08";

    int bit2 = 2;
    String bit2s = "02";


    //  packet += packetLength;

    packet += Information.RTF.hexVal;
    packet += Substate.running.hexVal; // doesnt matter for this usecase
    packet += padding(attributeCount,bit2);

    packet += attribute(RTFAttributes.value.hexVal,bit8s,padding(value, bit8));


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


  Map<String, String> decode(String packet) {

    //decodes packet for rtf

    Map<String, String> _settings = Map<String, String>();

    String sof = packet.substring(0,2); //7E start of frame

    int len = int.parse(packet.substring(2,4),radix: 16); //Packet Length

    print(len);

    String _machineState = packet.substring(4,6);
    String _ss = packet.substring(6,8);

    int _attributeLength = int.parse(packet.substring(8,10)); //should be 3

    //print(_attributeLength);

    int start = 10; //len("7EPL03AL")
    int end = start + len-8;

    if(sof!="7E"){
      print("RTF Message: Invalid Start Of Frame");
      throw FormatException("Status Message: Invalid Start Of Frame");
    }



    if(_machineState!=Information.RTF.hexVal){
      print("RTF Message: Invalid Request Settings Code");
      throw FormatException("RTF: Invalid Request Settings Code");
    }


    for(int i=start; i<end;){

      String t = packet.substring(i,i+2);


      int l = int.parse(packet.substring(i+2,i+4));

      String val = packet.substring(i+4,i+4+l);

      String key = attributeName(t);

      double v; //int or double

      if(key == ""){
        i=i+4+l;
        throw FormatException("Invalid Attribute Type");
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

  String attributeName(String t){

    //chooses attribute based on substate


    if(t == RTFAttributes.value.hexVal){
      return RTFAttributes.value.name;
    }
    else{
      return "";
    }
  }

  String receiveRequest(){

    String packet = "";

    packet = Separator.sof.hexVal+"08"+Information.RTF.hexVal+RTFAttributes.value.hexVal+"00"+Separator.eof.hexVal;

    return packet;
  }
}

void main(){

  print(RTFMessage(value: "").receiveRequest());
}