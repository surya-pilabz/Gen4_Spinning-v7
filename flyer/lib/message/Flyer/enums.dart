

enum Separator {
  sof,
  eof
}

extension SeparatorExtension on Separator{

  String get hexVal {
    switch (this){

      case Separator.sof:
        return "7E";
      case Separator.eof:
        return "7E";
    }
  }
}


enum MachineId{
  cardingMachine,
  drawFrame,
  flyer,
  ringFrame,

}

//ignore
extension MachineIdExtension on MachineId{

  String get hexVal {
    switch (this){

      case MachineId.cardingMachine:
        return "01";
      case MachineId.drawFrame:
        return "02";
      case MachineId.flyer:
        return "03";
      case MachineId.ringFrame:
        return "04";

    }
  }
}


enum Information {
  impaired,
  requestSettings,
  settingsFromApp,
  settingsToApp,
  diagnostics,
  diagnosticResponse,
  machineState,
  carouselInfo,
  changeName,
  gearBoxSettingsFromApp,
  gearBoxSettingsFromMachine,
  RTF,
  log,
}

extension InformationExtension on Information{

  String get hexVal {
    switch (this){

      case Information.impaired:
        return "99";
      case Information.settingsFromApp:
        return "01";
      case Information.settingsToApp:
        return "02";
      case Information.requestSettings:
        return "03";
      case Information.diagnostics:
        return "04";
      case Information.diagnosticResponse:
        return "05";
      case Information.machineState:
        return "06";
      case Information.carouselInfo:
        return "07";
      case Information.gearBoxSettingsFromApp:
        return "08";

      case Information.gearBoxSettingsFromMachine:
        return "09";
      case Information.changeName:
        return "0A";
      case Information.RTF:
        return "0B";
      case Information.log:
        return "0C";
    }
  }
}

enum Substate{
  idle,
  running,
  pause,
  stop,
  homing,
  inching,
  error,
}

extension SubstateExtension on Substate{

  String get hexVal {
    switch (this){

      case Substate.idle:
        return "00";
      case Substate.running:
        return "01";
      case Substate.pause:
        return "02";
      case Substate.error:
        return "03";
      case Substate.homing:
        return "04";
      case Substate.inching:
        return "05";
      default:
        return "06";
    }
  }
}


enum Homing {
  leftLiftDistance,
  rightLiftDistance,
}

extension homingExtension on Homing{

  String get hexVal {
    switch (this){

      case Homing.rightLiftDistance:
        return "02";
      case Homing.leftLiftDistance:
        return "01";
      default:
        return "00";
    }
  }
}




enum Error{
  information,
  source,
  action
}

extension errorExtension on Error{

  String get hexVal {
    switch (this) {
      case Error.information:
        return "01";
      case Error.source:
        return "02";
      case Error.action:
        return "03";
      default:
        return "00";
    }
  }
}


enum Pause{
  pauseReason,
}

extension pauseExtension on Pause{

  String get hexVal {
    switch (this) {
      case Pause.pauseReason:
        return "01";
      default:
        return "00";
    }
  }
}

enum pauseReason{
  userPaused,
  creelSliverCut,
  coilerSliverCut,
  lapping,
}

extension pauseReasonExtension on pauseReason{

  String get hexVal {
    switch (this) {
      case pauseReason.userPaused:
        return "01";
      case pauseReason.creelSliverCut:
        return "02";
      case pauseReason.coilerSliverCut:
        return "03";
      case pauseReason.lapping:
        return "04";
      default:
        return "00";
    }
  }
}




enum ControlType{
  closedLoop,
  openLoop,
}

extension ControlTypeExtension on ControlType{

  String get hexVal {
    switch (this){

      case ControlType.closedLoop:
        return "02";
      case ControlType.openLoop:
        return "01";
    }
  }
}




enum DiagnosticAttributeType{
  kindOfTest,
  motorID,
  motorDirection,
  targetPercent,
  testTime,
  bedDistance,
}

extension DiagnosticAttributeTypeExtension on DiagnosticAttributeType{

  String get hexVal {
    switch (this){

      case DiagnosticAttributeType.kindOfTest:
        return "41";
      case DiagnosticAttributeType.motorID:
        return "40";
      case DiagnosticAttributeType.motorDirection:
        return "44";
      case DiagnosticAttributeType.targetPercent:
        return "42";
      case DiagnosticAttributeType.testTime:
        return "43";
      case DiagnosticAttributeType.bedDistance:
        return "45";
    }
  }
}

enum DiagnosticResponse{
  speedRPM,
  signalVoltage,
  current,
  power,
  lift,
}

extension DiagnosticResponseExtension on DiagnosticResponse{

  String get hexVal {
    switch (this){

      case DiagnosticResponse.speedRPM:
        return "01";
      case DiagnosticResponse.signalVoltage:
        return "02";
      case DiagnosticResponse.current:
        return "03";
      case DiagnosticResponse.power:
        return "04";
      case DiagnosticResponse.lift:
        return "05";
    }
  }
}

enum MotorDirection{
  defaultDirection,
  reverseDirection
}

extension MotorDirectionExtension on MotorDirection{

  String get hexVal {
    switch (this){

      case MotorDirection.defaultDirection:
        return "00";
      case MotorDirection.reverseDirection:
        return "01";
    }
  }
}

enum GearBoxSettings{
  start,
  stop,
  saveLeft,
  saveRight,
}

extension GearBoxSettingsExtension on GearBoxSettings{

  String get hexVal {
    switch (this){

      case GearBoxSettings.start:
        return "01";
      case GearBoxSettings.stop:
        return "02";
      case GearBoxSettings.saveLeft:
        return "03";
      case GearBoxSettings.saveRight:
        return "04";
    }
  }

}

enum RTFAttributes{
  value,
}

extension RTFAttributesExtension on RTFAttributes{

  String get hexVal {
    switch (this) {
      case RTFAttributes.value:
        return "01";
    }
  }
}

enum LogAttributes{
  enable,
  disable,
}

extension LogAttributesExtension on LogAttributes{

  String get hexVal {
    switch (this) {
      case LogAttributes.enable:
        return "01";
      case LogAttributes.disable:
        return "00";
    }
  }
}
