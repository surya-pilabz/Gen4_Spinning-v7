import 'dart:typed_data';


void main() {
  String hexString = 'A';
 // print(convertInt(hexString));// 41.43949999999996

  print(hexConvert(8.8));
}

double convert(String hexString) {

  int l = hexString.length;

  String s = hexString;

  //print(int.parse(s, radix: 16));
  return double.parse((ByteData(4)..setUint32(0, int.parse(s, radix: 16))).getFloat32(0).toDouble().toStringAsFixed(4));
}

String hexConvert(double d){

  String val = "";

  var bdata = ByteData(8);
  bdata.setFloat32(0, d);
  int v = bdata.getInt32(0);

  val = v.toRadixString(16);

  return val;
}


String padding(String str,int no){

  //pad with 4

  String s;
  int len;

  s = str;
  len = str.length;


  for(int i = 0;i < no-len;i++){
    s = "0"+s;
  }

  return s;
}