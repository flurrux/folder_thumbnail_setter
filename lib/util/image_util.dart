import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageUtil {

  // loading image from *arbitrary* paths
  static Future<ui.Image> loadUIImageByPath(
    String path,
  ) async {

    final input = File(path);
    final bytes = await input.readAsBytes();
    return _makeImageFromBytes(bytes);
  }

  // loading iamges from the *local assets* folder
  static Future<ui.Image> loadAssetUIImage(
    String path, int width, int height
  ) async {
    
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    return _makeImageFromBytes(bytes);
  }

  static Future<ui.Image> _makeImageFromBytes(Uint8List bytes){
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }


  static Future<img.Image> convertUIImageToImg(
    ui.Image source
  ) async {

    final byteData = await source.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    return img.Image.fromBytes(
      bytes: byteData!.buffer,
      width: source.width,
      height: source.height,
      numChannels: 4
    );
  }

}
