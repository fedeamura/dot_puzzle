import 'package:dot_puzzle/widget/common/puzzle/index.dart';

class PuzzleController {
  PuzzleState? _state;

  attach(PuzzleState? state) {
    _state = state;
  }

  sort() async {
    await _state?.sort();
  }

  shuffle() async {
    await _state?.shuffle();
  }

  convertToImage() async {
    await _state?.convertToImage();
  }

  convertToNumbers() async {
    await _state?.convertToNumbers();
  }
}
