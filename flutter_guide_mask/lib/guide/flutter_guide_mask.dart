import 'package:flutter/material.dart';

import 'guide_config.dart';
import 'guide_manager.dart';

class FlutterGuideMask {
  static void showGuide(
    BuildContext context,
    List<String> guideKeys, {
    @required GuideMaskBuilder builder,
    Function(List<String> keys) onShow,
  }) {
    GuideManager().showGuide(
      context,
      guideKeys,
      builder: builder,
      onShow: onShow,
    );
  }

  static void dismissGuide() {
    GuideManager().dismissGuide();
  }
}

typedef GuideMaskBuilder = Widget Function(
    BuildContext context, List<GuideData> dataList);
