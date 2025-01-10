import 'enums.dart';

class ErrorMessage{

  Map<String, String> decode(String packet){

    Map<String, String> _errorInfo = Map<String, String>();

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
      throw FormatException("Error Message: Invalid Start Of Frame");
    }

    String _ssn = substateName(_ss);

    if(_ssn != ""){
      _errorInfo["substate"] = _ssn;
    }

    else{
      throw FormatException("Error Message: Invalid Substate");
    }

    if(_machineState!=Information.machineState.hexVal){
      throw FormatException("Error Message: Invalid Request Settings Code");
    }

    for(int i=start; i<end;){

      String t = packet.substring(i,i+2);


      int l = int.parse(packet.substring(i+2,i+4));

      String val = packet.substring(i+4,i+4+l);

      String key = attributeName(t);

      String v; //int or double

      if(key == ""){
        i=i+4+l;
        continue;
        //throw FormatException("Invalid Attribute Type");
      }


      v = int.parse(val,radix: 16).toString();


      if(key=="errorSource"){
        _errorInfo[key] = getErrorSource(v);
      }
      else if(key=="errorReason"){
        _errorInfo[key] = getReason(v);
      }
      else if(key=="errorCode"){
        _errorInfo[key] = v;
      }
      else{
        i=i+4+l;
        continue;
      }


      i=i+4+l;
    }

    return _errorInfo;
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

    if(t=="02"){
      return "errorSource";
    }
    else if(t=="01"){
      return "errorReason";
    }
    else if(t=="03"){
      return "errorCode";
    }
    else{
      return "";
    }
  }

  String getReason(String e){


    const Map<String, String> _errorDict = {
      "2":"Over Current",
      "4":"Over Voltage",
      "8":"Under voltage",
      "16":"Motor Thermistor Fault",
      "32":"MOSFET Thermistor Fault",
      "64":"Motor Over Temperature",
      "128":"MOSFET Over Temperature",
      "256":"EEPROM Write Error",
      "512":"EEPROM Bad Values",
      "1024":"Tracking Error",
      "2048":"Motor Encoder Setup Error",
      "4096":"Lift Pos Tracking Error",
      "8192":"Lift Synchronicity Fail",
      "16384":"Lift Out Of Bounds Error",
      "32768":"Eeprom Bad Homing Position",
      "96": "SMPS Error",
      "97":"Ack Error",
      "98":"Can Cut Error",
      "99":"Lift Relative Position Error",
    };

    if(_errorDict.containsKey(e)){
      return _errorDict[e]!;
    }
    else{
      return "";
    }
  }

  String getErrorSource(String e){

    print("get reason:$e");
    Map<String,String> _errSrc = {
      "1":"Calender",
      "8":"Lift Left",
      "9":"Lift Right",
      "11":"MotherBoard",
      "12":"Can Bus",
      "13":"Lifts",
      "14":"System",
    };

    if(_errSrc.containsKey(e)){

      return _errSrc[e]!;
    }
    else{
      return "";
    }
  }

}