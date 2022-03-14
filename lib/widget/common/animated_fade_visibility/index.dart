import 'package:flutter/material.dart';

class AnimatedFadeVisibility extends StatelessWidget {
  final bool visible;
  final Duration duration;
  final Widget child;

  const AnimatedFadeVisibility({
    Key? key,
    this.visible = true,
    this.duration = const Duration(milliseconds: 300),
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: duration,
        opacity: visible ? 1.0 : 0.0,
        child: child,
      ),
    );
  }
}
