import 'Flyer/enums.dart';


class LogMessage{

  String enableLog(){

    String packet = "";


    packet = Separator.sof.hexVal+"08"+Information.log.hexVal+LogAttributes.enable.hexVal+"00"+Separator.eof.hexVal;

    return packet;
  }

  String disableLog(){

    String packet = "";


    packet = Separator.sof.hexVal+"08"+Information.log.hexVal+LogAttributes.disable.hexVal+"00"+Separator.eof.hexVal;

    return packet;
  }

}