import 'package:dot_puzzle/widget/screen/home/index.dart';
import 'package:dot_puzzle/widget/screen/splash/painter.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({Key? key}) : super(key: key);

  @override
  _ScreenSplashState createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PerlinNoise _perlinNoise;
  double _offset = 0;

  @override
  void initState() {
    _perlinNoise = PerlinNoise(octaves: 4, frequency: 0.15, seed: 0);
    _animationController = AnimationController(vsync: this);
    _animationController.addListener(() {
      _offset += 0.1;
    });
    _animate();
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(seconds: 5)).then((value) {
        if (!mounted) return;
        _goToHome();
      });
    });
  }

  _animate() {
    _animationController.duration = const Duration(seconds: 5);
    _animationController.forward(from: 0.0).then((value) => _animate());
  }

  _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: const ScreenHome(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => CustomPaint(
            painter: CustomBackgroundPainter(
              offset: _offset,
              perlinNoise: _perlinNoise,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}
