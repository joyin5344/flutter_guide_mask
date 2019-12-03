import 'dart:math';

import 'package:flutter/material.dart';

import 'guide_config.dart';
import 'guide_manager.dart';

class GuideTarget extends StatefulWidget {
  final Widget child;
  final String name;
  final bool ignore;
  final GuideViewType type;
  final CircleType circleType;
  final Radius rectRadius;
  final EdgeInsets padding;

  GuideTarget({
    @required this.child,
    @required this.name,
    this.type = GuideViewType.RRect,
    this.circleType = CircleType.max,
    this.rectRadius = const Radius.circular(0.0),
    this.padding = const EdgeInsets.all(0),
    this.ignore = false,
    Key key,
  })  : assert(name != null),
        super(key: key);

  @override
  State createState() => GuideTargetSate();
}

class GuideTargetSate extends State<GuideTarget> {
  LayerLink layerLink = new LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    if (!widget.ignore) {
      GuideManager().registerGuideData(widget.name, this);
    }
  }

  @override
  void dispose() {
    if (!widget.ignore) {
      GuideManager().unregisterGuideData(widget.name);
    }
    super.dispose();
  }

  GuideData generateGuideData() {
    RenderBox box = context.findRenderObject();
    if (box == null) {
      return null;
    }
    Offset offset = box.localToGlobal(Offset.zero);
    Size size = box.size;

    GuideData data = GuideData(
      widget.type,
      name: widget.name,
    );
    if (widget.type == GuideViewType.Circle) {
      double radius;
      if (widget.circleType == CircleType.width) {
        radius = size.width / 2;
      } else if (widget.circleType == CircleType.height) {
        radius = size.height / 2;
      } else {
        radius = max(size.width, size.height) / 2;
      }
      data.circle = GuideCircle(
          offset.translate(size.width / 2, size.height / 2),
          radius + widget.padding.left);
    } else {
      data.rRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            offset.dx - widget.padding.left,
            offset.dy - widget.padding.top,
            size.width + widget.padding.horizontal,
            size.height + widget.padding.vertical,
          ),
          widget.rectRadius);
    }
    return data;
  }
}
