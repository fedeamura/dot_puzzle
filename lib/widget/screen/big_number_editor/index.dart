import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScreenBigNumberEditor extends StatefulWidget {
  const ScreenBigNumberEditor({Key? key}) : super(key: key);

  @override
  _ScreenBigNumberEditorState createState() => _ScreenBigNumberEditorState();
}

class _ScreenBigNumberEditorState extends State<ScreenBigNumberEditor> {
  final int _w = 19;
  Color? _color;
  var _colors = <math.Point<int>, Color>{};

  @override
  void initState() {
    // int x = ((_w - _nW)/2).round();
    // int y = ((_w - _nH)/2).round();
    //
    // for (int j = y; j < _nH + y; j++) {
    //   for (int i = x; i < _nW + x; i++) {
    //     _colors[math.Point<int>(i, j)] = Colors.black;
    //   }
    // }

    final _numberColors = [Colors.black, Colors.white];

    Color? _parseColor(dynamic value) {
      try {
        return _numberColors[int.parse(value)];
      } catch (error) {
        return null;
      }
    }

    math.Point<int>? _parsePoint(dynamic val1, dynamic val2) {
      try {
        return math.Point<int>(int.parse(val1), int.parse(val2));
      } catch (error) {
        return null;
      }
    }

    int deltaX = -1;
    int deltaY = -1;

    const representation =
        "4,5,0;5,5,0;6,5,0;7,5,0;8,5,0;11,5,0;12,5,0;13,5,0;14,5,0;15,5,0;16,5,0;3,6,0;4,6,0;5,6,1;6,6,1;7,6,1;8,6,0;10,6,0;11,6,1;12,6,1;13,6,1;14,6,1;15,6,1;16,6,1;17,6,0;3,7,0;4,7,1;5,7,1;6,7,1;7,7,1;8,7,0;10,7,0;11,7,1;12,7,1;13,7,1;14,7,1;15,7,1;16,7,1;17,7,0;18,7,0;3,8,0;4,8,1;5,8,1;6,8,1;7,8,1;8,8,0;10,8,0;11,8,1;12,8,1;13,8,0;14,8,0;15,8,0;16,8,0;17,8,0;18,8,0;3,9,0;4,9,0;5,9,1;6,9,1;7,9,1;8,9,0;10,9,0;11,9,1;12,9,1;13,9,1;14,9,1;15,9,1;16,9,0;17,9,0;18,9,0;4,10,0;5,10,1;6,10,1;7,10,1;8,10,0;9,10,0;10,10,0;11,10,1;12,10,1;13,10,1;14,10,1;15,10,1;16,10,1;17,10,0;18,10,0;2,11,0;3,11,0;4,11,0;5,11,1;6,11,1;7,11,1;8,11,0;9,11,0;10,11,0;11,11,0;12,11,0;13,11,0;14,11,0;15,11,1;16,11,1;17,11,0;18,11,0;2,12,0;3,12,1;4,12,1;5,12,1;6,12,1;7,12,1;8,12,1;9,12,0;10,12,0;11,12,1;12,12,1;13,12,1;14,12,1;15,12,1;16,12,1;17,12,0;18,12,0;2,13,0;3,13,1;4,13,1;5,13,1;6,13,1;7,13,1;8,13,1;9,13,0;10,13,0;11,13,1;12,13,1;13,13,1;14,13,1;15,13,1;16,13,0;17,13,0;18,13,0;2,14,0;3,14,0;4,14,0;5,14,0;6,14,0;7,14,0;8,14,0;9,14,0;10,14,0;11,14,0;12,14,0;13,14,0;14,14,0;15,14,0;16,14,0;17,14,0;18,14,0;3,15,0;4,15,0;5,15,0;6,15,0;7,15,0;8,15,0;9,15,0;11,15,0;12,15,0;13,15,0;14,15,0;15,15,0;16,15,0;17,15,0;9,9,0;9,8,0;9,7,0;9,6,0;10,5,0;17,5,0;18,6,0;10,15,0";
    final items = representation.split(";");
    final result = <math.Point<int>, Color>{};
    for (var item in items) {
      final itemParts = item.split(",");
      if (itemParts.length != 3) continue;

      final point = _parsePoint(itemParts[0], itemParts[1]);
      if (point == null) continue;

      final color = _parseColor(itemParts[2]);
      if (color == null) continue;

      result[math.Point<int>(point.x + deltaX, point.y + deltaY)] = color;
    }

    _colors = result;
    super.initState();
  }

  _onPressed(int i, int j) {
    final p = math.Point<int>(i, j);
    if (_color == null) {
      _colors.removeWhere((key, value) => key == p);
    } else {
      _colors[p] = _color!;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final representation = _colors.entries.map((e) {
      String c;
      if (e.value == Colors.black) {
        c = "0";
      } else {
        c = "1";
      }
      return "${e.key.x},${e.key.y},$c";
    }).join(";");

    return Scaffold(
      body: Container(
        color: Colors.grey,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: MediaQuery.of(context).padding.top + 20.0,
          bottom: 20.0,
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Column(
                    children: [
                      for (int j = 0; j < _w; j++)
                        Expanded(
                          child: Row(
                            children: [
                              for (int i = 0; i < _w; i++)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _onPressed(i, j),
                                    child: Container(
                                      margin: const EdgeInsets.all(1.0),
                                      decoration: BoxDecoration(
                                        color: _colors[math.Point<int>(i, j)],
                                        border: Border.all(color: Colors.white, width: 1),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: SelectableText(representation),
            ),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _color = null;
                    });
                  },
                  child: const Text("Delete"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _color = Colors.white;
                    });
                  },
                  child: const Text("White"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _color = Colors.black;
                    });
                  },
                  child: const Text("Black"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
