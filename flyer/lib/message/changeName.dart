
import 'Flyer/enums.dart';

class ChangeName{

  String changeName(String n){

    String packet = "";


    if(n=="" || n== " " || n.length>8){
      throw FormatException("Invalid Name Format");
    }

    packet = Separator.sof.hexVal+"12"+Information.changeName.hexVal+"01"+"01"+"0${n.length}"+n+Separator.eof.hexVal;
    return packet;
  }
}