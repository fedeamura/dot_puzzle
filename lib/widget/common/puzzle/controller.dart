import 'package:dot_puzzle/widget/common/puzzle/index.dart';

class PuzzleController {
  PuzzleState? _state;

  attach(PuzzleState? state) {
    _state = state;
  }

  sort() {
    _state?.sort();
  }

  shuffle() {
    _state?.reset();
  }

  convertToImage() {
    _state?.convertToImage();
  }

  convertToNumbers() {
    _state?.convertToNumbers();
  }

  bool get imageMode {
    return _state?.imageMode ?? false;
  }

  Future<void> explode({Duration duration = Duration.zero}) async {
    await _state?.explode(duration: duration);
  }
}
