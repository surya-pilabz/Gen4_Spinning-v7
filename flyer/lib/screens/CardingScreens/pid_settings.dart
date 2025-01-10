import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import '../../services/snackbar_service.dart';

class PIDSettingsCarding extends StatefulWidget {
  final BluetoothConnection? connection;
  final Stream<Uint8List>? settingsStream;

  const PIDSettingsCarding({
    Key? key,
    this.connection,
    this.settingsStream
  }) : super(key: key);

  @override
  _PIDSettingsCardingState createState() => _PIDSettingsCardingState();
}

class _PIDSettingsCardingState extends State<PIDSettingsCarding> {
  final TextEditingController kP_ = TextEditingController();
  final TextEditingController kI_ = TextEditingController();
  final TextEditingController feedForward_ = TextEditingController();
  final TextEditingController startOffset_ = TextEditingController();

  final List<String> _motorName = ["CARD CYLINDER","BEATER CYLINDER","CAGE","CARDING FEED","BEATER FEED","COILER","PICKER CYLINDER","AF FEED"];
  late String selectedDropDownMotor = _motorName.first;
  late String previousDropDownMotor = _motorName.first;

  @override
  Widget build(BuildContext context) {
    bool _enabled = true;  // You can modify this based on your provider state

    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.65),
                1: FractionColumnWidth(0.30),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                _customRowWithDropDown("Motor Name", _motorName),
                _customRow("Kp", kP_, isFloat: true, enabled: _enabled),
                _customRow("Ki", kI_, isFloat: true, enabled: _enabled),
                _customRow("Feed Forward", feedForward_, isFloat: false, enabled: _enabled),
                _customRow("Start Offset", startOffset_, isFloat: false, enabled: _enabled),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.input,
                  label: "Input",
                  onPressed: () => _requestPIDSettings(),
                ),
                _buildActionButton(
                  icon: Icons.save,
                  label: "Save",
                  onPressed: () => _savePIDSettings(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar(){

    return AppBar(
      title: const Text("PID Settings"),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      shadowColor: Theme.of(context).highlightColor,
      centerTitle: true,

      leading: IconButton(
        icon: const Icon(Icons.arrow_back,color: Colors.black,),
        onPressed: (){
          Navigator.of(context).pop();
        },
      ),

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.blue,Colors.lightGreen]),
        ),
      ),


    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Theme.of(context).primaryColor),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  TableRow _customRow(String label, TextEditingController controller,
      {bool isFloat = true, bool enabled = true}) {
    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(top: 12.5, bottom: 2.5),
            color: enabled ? Colors.transparent : Colors.grey.shade400,
            child: TextField(
              enabled: enabled,
              controller: controller,
              inputFormatters: <TextInputFormatter>[
                isFloat
                    ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                    : FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                FilteringTextInputFormatter.deny('-'),
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _customRowWithDropDown(String label, List<String> dropDownList) {
    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            child: DropdownButton<String>(
              value: selectedDropDownMotor,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              isExpanded: true,
              style: TextStyle(color: Theme.of(context).primaryColor),
              underline: Container(
                height: 2,
                color: Theme.of(context).primaryColor,
              ),
              onChanged: (String? value) {
                setState(() {
                  if (previousDropDownMotor != value) {
                    selectedDropDownMotor = value!;
                    _clearFields();
                    previousDropDownMotor = value;
                  }
                });
              },
              items: dropDownList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _clearFields() {
    kP_.text = "";
    kI_.text = "";
    feedForward_.text = "";
    startOffset_.text = "";
  }

  void _requestPIDSettings() {
    // TODO - Implement your PID settings request logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBarService(
        message: "Requesting PID settings...",
        color: Colors.blue,
      ).snackBar(),
    );
  }

  void _savePIDSettings() {
    // TODO - Implement your PID settings save logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBarService(
        message: "Saving PID settings...",
        color: Colors.green,
      ).snackBar(),
    );
  }
}