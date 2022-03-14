import 'package:dot_puzzle/service/audio/_interface.dart';
import 'package:just_audio/just_audio.dart';

class AudioServiceImpl extends AudioService {
  @override
  Future<void> playAsset(String path) async {
    final audioPlayer = AudioPlayer();
    audioPlayer.setAsset(path, preload: true);
    await audioPlayer.play();
  }
}
