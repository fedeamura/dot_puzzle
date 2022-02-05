import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:dot_puzzle/service/puzzle/index.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'widget/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final puzzleService = PuzzleServiceImpl();
  await puzzleService.init();
  GetIt.I.registerSingleton<PuzzleService>(puzzleService);
  runApp(const CustomApp());
}
