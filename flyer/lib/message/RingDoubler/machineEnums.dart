
enum SettingsAttribute{
  inputYarn,
  outputYarnDia,
  spindleSpeed,
  twistPerInch,
  packageHeight,
  diaBuildFactor,
  windingClosenessFactor,
  windingOffsetCoils,
}

extension SettingsAttributeTypeExtension on SettingsAttribute{

  String get hexVal {
    switch (this){
      case SettingsAttribute.inputYarn:
        return "90";
      case SettingsAttribute.outputYarnDia:
        return "91";
      case SettingsAttribute.spindleSpeed:
        return "92";
      case SettingsAttribute.twistPerInch:
        return "93";
      case SettingsAttribute.packageHeight:
        return "94";
      case SettingsAttribute.diaBuildFactor:
        return "95";
      case SettingsAttribute.windingClosenessFactor:
        return "96";
      case SettingsAttribute.windingOffsetCoils:
        return "97";
    }
  }
}

enum MotorId{
  calender,
  lift,
  liftLeft,
  liftRight,
}

extension MotorIdExtension on MotorId{

  String get hexVal {
    switch (this){

      case MotorId.calender:
        return "01";
      case MotorId.lift:
        return "07";
      case MotorId.liftLeft:
        return "08";
      case MotorId.liftRight:
        return "09";

    }
  }
}

enum Running{
  leftLiftDistance,
  rightLiftDistance,
  layers,
  motorTemp,
  MOSFETTemp,
  current,
  RPM,
  outputMtrs,
  totalPower,
  whatInfo,
  weight,
}

extension runningExtension on Running{

  String get hexVal {
    switch (this) {
      case Running.leftLiftDistance:
        return "01";
      case Running.rightLiftDistance:
        return "02";
      case Running.layers:
        return "03";
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
      case Running.weight:
        return "10";
      default:
        return "00";
    }
  }
}
