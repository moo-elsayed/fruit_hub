import 'package:flutter/material.dart';

class SnapScrollPhysics extends ScrollPhysics {
  const SnapScrollPhysics({super.parent, required this.itemExtent});

  final double itemExtent;

  @override
  SnapScrollPhysics applyTo(ScrollPhysics? ancestor) => SnapScrollPhysics(
    parent: buildParent(ancestor),
    itemExtent: itemExtent,
  );

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    double page = position.pixels / itemExtent;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return (page.roundToDouble() * itemExtent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    final target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
