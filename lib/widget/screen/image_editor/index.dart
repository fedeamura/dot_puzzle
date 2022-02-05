import 'dart:typed_data';

import 'package:dot_puzzle/core/color.dart';
import 'package:dot_puzzle/widget/screen/image_editor/painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

class ScreenImage extends StatefulWidget {
  const ScreenImage({Key? key}) : super(key: key);

  @override
  _ScreenImageState createState() => _ScreenImageState();
}

class _ScreenImageState extends State<ScreenImage> {
  Uint8List? _bytes;
  final int _size = 76;
  final _points = <math.Point<int>, Color>{};
  String _representation = "";
  bool _result = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  _init() async {
    setState(() {
      _bytes = null;
      _points.clear();
    });

    final data = await rootBundle.load("assets/images/yellow.png");
    _bytes = data.buffer.asUint8List();

    final image = img.decodeImage(_bytes!);

    int abgrToArgb(int argbColor) {
      int r = (argbColor >> 16) & 0xFF;
      int b = argbColor & 0xFF;
      return (argbColor & 0xFF00FF00) | (b << 16) | r;
    }

    for (int j = 0; j < _size; j++) {
      for (int i = 0; i < _size; i++) {
        var color = Color(abgrToArgb(image!.getPixelSafe(i, j)));
        _points[math.Point<int>(i, j)] = color;
      }
    }

    _representation = _points.entries.map((e) {
      return "${e.key.x},${e.key.y},${ColorUtils.toHexString(e.value)}";
    }).join(";");

    _points.clear();
    _representation.split(";").forEach((item) {
      final parts = item.split(",");
      final pos = math.Point<int>(int.parse(parts[0]), int.parse(parts[1]));
      final color = ColorUtils.fromHexString(parts[2]);
      if (color != null) {
        _points[pos] = color;
      }
    });
    setState(() {});
  }

  _copyRepresentationToClipboard() {
    Clipboard.setData(ClipboardData(text: _representation));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image editor"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _init,
          ),
          IconButton(
            icon: const Icon(Icons.insert_drive_file_outlined),
            onPressed: _bytes == null ? null : () => setState(() => _result = !_result),
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Builder(
          builder: (context) {
            if (_bytes == null) return Container();
            if (_result) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: 16.0 + MediaQuery.of(context).viewPadding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: _copyRepresentationToClipboard,
                      child: const Text("Copy to clipboard"),
                    ),
                    SelectableText(_representation),
                  ],
                ),
              );
            }

            return Container(
              margin: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewPadding.bottom,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.memory(
                        _bytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        painter: ImageEditorPainter(
                          points: _points,
                          size: _size,
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
