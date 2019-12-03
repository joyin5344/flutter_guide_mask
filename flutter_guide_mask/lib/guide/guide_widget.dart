import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'flutter_guide_mask.dart';
import 'guide_config.dart';
import 'guide_manager.dart';

class GuideWidget extends StatefulWidget {
  final Color backgroundColor;
  final List<String> guideKeys;
  final GuideMaskBuilder builder;
  final double sigma;

  const GuideWidget({
    Key key,
    this.guideKeys,
    this.builder,
    this.backgroundColor = const Color(0xCC000000),
    this.sigma = 1.3,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GuideWidgetState();
}

class _GuideWidgetState extends State<GuideWidget> {
  List<String> guideKeys;
  StreamSubscription<String> _subscription;

  @override
  void initState() {
    guideKeys = widget.guideKeys;
    _subscription = GuideManager().addRemoveGuideKeyListener((key) {
      if (mounted) {
        setState(() {
          if (guideKeys != null) {
            guideKeys.remove(key);
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<GuideData> guideList;
    if (guideKeys != null && guideKeys.isNotEmpty) {
      guideList = GuideManager().getGuideData(guideKeys);
    }
    if (guideList == null || guideList.isEmpty) {
      return Container();
    }

    Size size = MediaQuery.of(context).size;

    Path path = Path();
    guideList.forEach((data) {
      if (data.type == GuideViewType.Circle) {
        path.addOval(Rect.fromCircle(
            center: data.circle.offset, radius: data.circle.radius));
      } else if (data.type == GuideViewType.RRect) {
        path.addRRect(data.rRect);
      }
    });
    final clipper = _MarkClipper(path);
    return Container(
      width: size.width,
      height: size.height,
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: clipper,
            child: BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: widget.sigma, sigmaY: widget.sigma),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          AbsorbPointer(
            child: CustomPaint(
              size: Size(size.width, size.height),
              foregroundPainter: _MyPainter(
                backgroundColor: widget.backgroundColor,
                path: path,
              ),
            ),
          ),
          widget.builder != null
              ? widget.builder(context, guideList) ?? Container()
              : Container(),
        ],
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  Color backgroundColor;
  Path path;

  _MyPainter({
    this.backgroundColor,
    this.path,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(backgroundColor, BlendMode.dstATop);
    Paint paint = Paint()..blendMode = BlendMode.clear;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _MarkClipper extends CustomClipper<Path> {
  final Path path;

  _MarkClipper(this.path);

  @override
  Path getClip(Size size) => Path.combine(
      PathOperation.difference, Path()..addRect(Offset.zero & size), path);

  @override
  bool shouldReclip(_MarkClipper old) => path != old.path;
}
