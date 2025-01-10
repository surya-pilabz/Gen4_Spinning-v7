import 'enums.dart';

class ResetLengthCounterMessage {

  String ResetLengthCounter() {
    String packet = "";


    packet = Separator.sof.hexVal + "04" + Information.resetLengthCounter.hexVal + Separator.eof.hexVal;

    return packet;
  }
}