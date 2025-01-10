import 'package:flutter/material.dart';

class SnackBarService{

  final String message;
  final Color color;

  SnackBarService({required this.message,required this.color});

  SnackBar snackBar(){

    return SnackBar(
        content: Text(message,textAlign: TextAlign.center,),
        backgroundColor: color,
        duration: Duration(seconds: 1),
    );
  }
}