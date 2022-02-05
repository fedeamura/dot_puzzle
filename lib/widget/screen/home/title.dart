import 'package:flutter/material.dart';

class ScreenHomeTitle extends StatelessWidget {
  const ScreenHomeTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Puzzle Challenge",
      style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.black),
    );
  }
}
