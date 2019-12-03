import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_guide_mask.dart';
import 'guide_config.dart';
import 'guide_target_widget.dart';
import 'guide_widget.dart';

class GuideManager {
  static final GuideManager _instance = new GuideManager._internal();

  factory GuideManager() {
    return _instance;
  }

  GuideManager._internal() {
    this._guideInfo = {};
    _streamController = StreamController<String>.broadcast();
  }

  Map<String, GuideTargetSate> _guideInfo;

  OverlayEntry _overlayEntry;

  StreamController<String> _streamController;

  StreamSubscription<String> addRemoveGuideKeyListener(
      Function(String key) func) {
    return _streamController?.stream?.listen(func);
  }

  registerGuideData(String key, GuideTargetSate state) {
    _guideInfo[key] = state;
  }

  unregisterGuideData(String key) {
    _guideInfo.remove(key);
    _streamController?.sink?.add(key);
  }

  List<GuideData> getGuideData(List<String> keys) {
    if (keys != null && keys.isNotEmpty) {
      return _guideInfo?.keys
          ?.where((key) => keys.contains(key))
          ?.map((key) => _guideInfo[key])
          ?.map((state) => state.generateGuideData())
          ?.where((data) => data != null)
          ?.toList();
    }
    return null;
  }

  showGuide(
    BuildContext context,
    List<String> guideKeys, {
    @required GuideMaskBuilder builder,
    Function(List<String> keys) onShow,
  }) {
    if (guideKeys != null && guideKeys.length > 0) {
      bool show = false;
      guideKeys.forEach((key) {
        if (_guideInfo?.keys?.contains(key) ?? false) {
          show = true;
        }
      });
      if (!show) {
        return;
      }
    }
    dismissGuide();
    _overlayEntry = OverlayEntry(builder: (context) {
      return GuideWidget(
        guideKeys: guideKeys,
        builder: builder,
      );
    });
    Overlay.of(context).insert(_overlayEntry);
    if (onShow != null) {
      onShow(guideKeys);
    }
  }

  dismissGuide() {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }
}
