import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class CustomSpringCurve extends Curve {
  final double stiffness;
  final double damping;

  const CustomSpringCurve({
    this.stiffness = 70.0,
    this.damping = 20.0,
  });

  @override
  double transform(double t) => _sim(stiffness, damping).x(t) + t * (1 - _sim(stiffness, damping).x(1.0));
}

_sim(double stiffness, double damping) => SpringSimulation(
  SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: stiffness,
    ratio: 0.7,
  ),
  0.0,
  1.0,
  0.0,
);