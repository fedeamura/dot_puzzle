import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screen/home/index.dart';

class CustomApp extends StatefulWidget {
  const CustomApp({Key? key}) : super(key: key);

  @override
  _CustomAppState createState() => _CustomAppState();
}

class _CustomAppState extends State<CustomApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Dot Puzzle",
      debugShowCheckedModeBanner: false,
      home: const ScreenHome(),
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.pressStart2pTextTheme(ThemeData.dark().textTheme),
      ),
    );
  }
}
