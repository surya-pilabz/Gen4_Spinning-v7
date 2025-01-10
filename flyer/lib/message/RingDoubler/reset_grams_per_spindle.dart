import 'enums.dart';

class ResetGramsPerSpindleMessage {

  String ResetGramsPerSpindle() {
    String packet = "";


    packet = Separator.sof.hexVal + "04" + Information.resetGramsPerSpindle.hexVal + Separator.eof.hexVal;

    return packet;
  }
}