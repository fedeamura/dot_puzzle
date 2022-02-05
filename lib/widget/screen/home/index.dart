import 'package:dot_puzzle/widget/common/puzzle/controller.dart';
import 'package:dot_puzzle/widget/common/puzzle/index.dart';
import 'package:dot_puzzle/widget/screen/home/title.dart';
import 'package:dot_puzzle/widget/screen/image_editor/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final _puzzleController = PuzzleController();

  _onButtonSortPressed() {
    _puzzleController.sort();
  }

  _onButtonShufflePressed() {
    _puzzleController.shuffle();
  }

  _onButtonImagePressed() {
    _puzzleController.convertToImage();
  }

  _onButtonToNumbersPressed() {
    _puzzleController.convertToNumbers();
  }

  _goToImageEditor() {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const ScreenImage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       onPressed: _goToImageEditor,
      //       icon: const Icon(
      //         Icons.more_vert,
      //         color: Colors.black,
      //       ),
      //     ),
      //   ],
      // ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
          top: MediaQuery.of(context).padding.top,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                const ScreenHomeTitle(),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Puzzle(controller: _puzzleController),
                    ),
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  runSpacing: 8.0,
                  spacing: 8.0,
                  children: [
                    ElevatedButton(
                      onPressed: _onButtonSortPressed,
                      child: const Text("Sort"),
                    ),
                    ElevatedButton(
                      onPressed: _onButtonShufflePressed,
                      child: const Text("Shuffle"),
                    ),
                    ElevatedButton(
                      onPressed: _onButtonImagePressed,
                      child: const Text("To image"),
                    ),
                    ElevatedButton(
                      onPressed: _onButtonToNumbersPressed,
                      child: const Text("To numbers"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
