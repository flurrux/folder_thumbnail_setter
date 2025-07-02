import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:folder_thumbnail_setter/folder_icon_util/icon_sizes.dart';
import 'package:folder_thumbnail_setter/util/image_util.dart';
import 'package:folder_thumbnail_setter/util/render_util.dart';
import 'package:folder_thumbnail_setter/util/transform.dart';

class FolderIconGenerator {

  static Future<ui.Image> generate(
    ui.Image sourceImage,
    Transform2D transform
  ) async {

    final fullIconSize = FolderIconSizes.fullIconSize;

    final int fullWidth = fullIconSize.width.round();
    final int fullHeight = fullIconSize.height.round();

    final folderBackdrop = await ImageUtil.loadAssetUIImage(
      "assets/folder-background.png", fullWidth, fullHeight
    );

    final resultImage = await RenderUtil.renderToImage(
      width: fullWidth,
      height: fullHeight,
      drawCallback: (canvas, size) {
        final paint = Paint();
        paint.filterQuality = FilterQuality.high;

        canvas.drawImage(
          folderBackdrop, Offset.zero, paint
        );

        canvas.clipRRect(
          RRect.fromRectAndRadius(
            FolderIconSizes.iconMask,
            Radius.circular(6)
          )
        );

        final scale = transform.scale;
        final translation = transform.translation;
        canvas.translate(translation.dx, translation.dy);
        canvas.scale(scale);
        canvas.rotate(transform.rotation);

        paint.isAntiAlias = true;

        canvas.drawImage(
          sourceImage,
          Offset.zero,
          paint
        );
      },
    );

    return resultImage;


    // var resultImage = img.PngDecoder().decode(imageBytes)!;
    
    // // i was experimenting with device pixel ratio by first
    // // drawing everything with a bigger size and then downscaling
    // // here, but the results look slightly worse.
    // resultImage = img.copyResize(
    //   resultImage,
    //   width: fullWidth,
    //   height: fullHeight,
    //   interpolation: img.Interpolation.cubic
    // );

    // return resultImage;
  }

}
