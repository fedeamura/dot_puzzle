import 'package:dot_puzzle/service/vibration/_interface.dart';
import 'package:vibration/vibration.dart';

class VibrationServiceImpl extends VibrationService {
  @override
  Future<void> vibrate({Duration? duration, int? amplitude}) async {
    final canVibrate = await Vibration.hasVibrator();
    if (canVibrate != true) return;

    await Vibration.vibrate(
      duration: duration != null ? duration.inMilliseconds : 500,
      amplitude: amplitude ?? -1,
    );
  }
}
