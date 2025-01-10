import 'Flyer/enums.dart';

class ImPaired{

  String createPacket(){

    String packet = "";
    String packetLength = "08";
    String attributeLength = "00";

    packet = Separator.sof.hexVal+packetLength+Information.impaired.hexVal+Substate.idle.hexVal+attributeLength+Separator.eof.hexVal;

    return packet;
  }
}


void main(){
  print(ImPaired().createPacket());
}