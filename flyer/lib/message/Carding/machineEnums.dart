

enum Running{
  leftLiftDistance,
  rightLiftDistance,
  layers,
  ductSensor,
  coilerSensor,
  motorTemp,
  MOSFETTemp,
  current,
  RPM,
  outputMtrs,
  totalPower,
  deliveryMtrsPerMin,
  whatInfo,
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
      case Running.ductSensor:
        return "0B";
      case Running.coilerSensor:
        return "0C";
      case Running.deliveryMtrsPerMin:
        return "0D";
      default:
        return "00";
    }
  }
}

enum SettingsAttribute{
   deliverySpeed,
   cardFeedRatio,
   lengthLimit,
   cylSpeed,
   btrSpeed,
   pickerCylSpeed,
   btrFeed,
   afFeed
}

extension SettingsAttributeTypeExtension on SettingsAttribute{

  String get hexVal {
    switch (this){
      case SettingsAttribute.deliverySpeed:
        return "80";
      case SettingsAttribute.cardFeedRatio:
        return "81";
      case SettingsAttribute.lengthLimit:
        return "82";
      case SettingsAttribute.cylSpeed:
        return "83";
      case SettingsAttribute.btrSpeed:
        return "84";
      case SettingsAttribute.pickerCylSpeed:
        return "85";
      case SettingsAttribute.btrFeed:
        return "86";
      case SettingsAttribute.afFeed:
        return "87";
    }
  }
}


enum MotorId{
  cylinder,
  beater,
  cage,
  cylinderFeed,
  beaterFeed,
  coiler,
  picker_cylinder,
  af_feed
}

extension MotorIdExtension on MotorId{

  String get hexVal {
    switch (this){

      case MotorId.cylinder:
        return "01";
      case MotorId.beater:
        return "02";
      case MotorId.cage:
        return "03";
      case MotorId.cylinderFeed:
        return "04";
      case MotorId.beaterFeed:
        return "05";
      case MotorId.coiler:
        return "06";
      case MotorId.picker_cylinder:
        return "07";
      case MotorId.af_feed:
        return "08";
    }
  }
}

//only for carding

enum SettingsUpdate{
  update,
  save
}

extension SettingsUpdateExtension on SettingsUpdate{

  String get hexVal {
    switch (this) {
      case SettingsUpdate.update:
        return "01";
      case SettingsUpdate.save:
        return "00";
    }
  }
}


