import 'package:flutter/material.dart';

enum GuideViewType {
  RRect,
  Circle,
}

enum CircleType {
  max,
  width,
  height,
}

class GuideData {
  String name;
  GuideViewType type;
  RRect rRect;
  GuideCircle circle;

  GuideData(
    this.type, {
    this.rRect,
    this.circle,
    this.name,
  });
}

class GuideCircle {
  Offset offset;
  double radius;

  GuideCircle(
    this.offset,
    this.radius,
  );
}
