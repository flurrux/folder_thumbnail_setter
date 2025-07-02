import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';


class RenderUtil {

  static Future<ui.Image> renderToImage({
    required void Function(Canvas canvas, Size size) drawCallback,
    required int width,
    required int height,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());

    // final dpr = _Util.getDevicePixelRatio();
    // canvas.scale(dpr);
    drawCallback(canvas, size);

    final picture = recorder.endRecording();

    final uiImage = await picture.toImage(
      width, height,
      // (dpr * width).ceil(),
      // (dpr * height).ceil()
    );

    return uiImage;

    // final byteData = await uiImage.toByteData(format: format);
    // return byteData!.buffer.asUint8List();
  }

  static double getDevicePixelRatio(){
    return ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  }

}
