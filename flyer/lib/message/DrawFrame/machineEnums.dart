
enum SettingsAttribute{
  deliverySpeed,
  draft,
  lengthLimit,
  rampUpTime,
  rampDownTime,
  creelTensionFactor,
}

extension SettingsAttributeTypeExtension on SettingsAttribute{

  String get hexVal {
    switch (this){
      case SettingsAttribute.deliverySpeed:
        return "70";
      case SettingsAttribute.draft:
        return "71";
      case SettingsAttribute.lengthLimit:
        return "72";
      case SettingsAttribute.rampUpTime:
        return "73";
      case SettingsAttribute.rampDownTime:
        return "74";
      case SettingsAttribute.creelTensionFactor:
        return "75";
    }
  }
}


enum MotorId{
  frontRoller,
  backRoller,
  creel,
  drafting,
}

extension MotorIdExtension on MotorId{

  String get hexVal {
    switch (this){

      case MotorId.frontRoller:
        return "01";
      case MotorId.backRoller:
        return "02";
      case MotorId.creel:
        return "03";
      case MotorId.drafting:
        return "05";
    }
  }
}

enum Running{
  currentLength,
  motorTemp,
  MOSFETTemp,
  current,
  RPM,
  outputMtrs,
  whatInfo,
  totalPower,
  deliveryMtrsPerMin,

}

extension runningExtension on Running{

  String get hexVal {
    switch (this) {
      case Running.currentLength:
        return "0E";
      case Running.motorTemp:
        return "04";
      case Running.MOSFETTemp:
        return "05";
      case Running.current:
        return "06";
      case Running.RPM:
        return "07";
      case Running.outputMtrs:
        return "08";
      case Running.whatInfo:
        return "09";
      case Running.totalPower:
        return "0A";
      case Running.deliveryMtrsPerMin:
        return "0D";
      default:
        return "00";
    }
  }
}