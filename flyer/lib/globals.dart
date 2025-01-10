library my_prj.globals;

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

bool isRecording = false;
bool isConnected = false;
bool pidEnabled = false;
bool isListening = false;
BluetoothDevice? selectedDevice;

String password = "7110eda4d09e062aa5e4a390b0a572ac0d2c0220";



Map<String,List<int>> diagnosticLimits = {
   "bedTravelDistance": [1,200],
};
