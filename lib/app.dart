import 'package:dot_puzzle/home.dart';
import 'package:flutter/material.dart';

class CustomApp extends StatefulWidget {
  const CustomApp({Key? key}) : super(key: key);

  @override
  _CustomAppState createState() => _CustomAppState();
}

class _CustomAppState extends State<CustomApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScreenHome(),
    );
  }
}
