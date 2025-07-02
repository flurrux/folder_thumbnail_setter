
import 'dart:math';

import 'package:flutter/widgets.dart';

class Transform2D {

  final Offset translation;
  final double rotation;
  final double scale;

  Transform2D({
    required this.translation,
    required this.rotation,
    required this.scale,
  });

  static Transform2D identity = Transform2D(
    translation: Offset.zero,
    rotation: 0,
    scale: 1,
  );

  Matrix4 toMatrix4(){
    final cosine = scale * cos(rotation);
    final sine = scale * sin(rotation);
    final posX = translation.dx;
    final posY = translation.dy;

    return Matrix4(
      cosine,  sine,    0,  0,
      -sine,   cosine,  0,  0,
      0,       0,       1,  0,
      posX,    posY,    0,  1
    );
  }


  // when we transform the image (e.g scale or rotate), then we
  // want to keep the pixel under the mouse point fixed.
  static Transform2D transformAndKeepGlobalPointFixed({
    required Offset globalPoint,
    required Transform2D Function(Transform2D) operation,
    required Transform2D transform
  }){
    final Offset localPointBefore = transform.inverseTransformPoint(
      globalPoint
    );

    final Transform2D withOperationApplied = operation(transform);

    final Offset globalPointAfter = withOperationApplied.transformPoint(
      localPointBefore
    );

    return withOperationApplied.copyWithTranslationDelta(
      -(globalPointAfter - globalPoint)
    );
  }


  // copy ---------------------------------

  copyWithTranslation(Offset newTranslation){
    return Transform2D(
      translation: newTranslation,
      scale: scale,
      rotation: rotation,
    );
  }

  copyWithTranslationDelta(Offset delta){
    return copyWithTranslation( translation + delta );
  }


  copyWithRotation(double newRotation){
    return Transform2D(
      rotation: newRotation,
      translation: translation,
      scale: scale,
    );
  }

  copyWithRotationDelta(double delta){
    return copyWithRotation( rotation + delta );
  }


  copyWithScale(double newScale){
    return Transform2D(
      scale: newScale,
      rotation: rotation,
      translation: translation,
    );
  }


  // transform point ---------------

  transformPoint(Offset point){
    return (
      translation +
      scaleAndRotatePoint(scale, rotation)(point)
    );
  }

  inverseTransformPoint(Offset point){
    var transformFn = scaleAndRotatePoint(
      1 / scale, -rotation
    );

    return transformFn(point - translation);
  }

  static Offset Function(Offset) scaleAndRotatePoint(
    double scale, double rotation,
  ){
    final c = scale * cos(rotation);
    final s = scale * sin(rotation);

    return (point){
      final dx = point.dx;
      final dy = point.dy;

      return Offset(
        c * dx - s * dy,
        c * dy + s * dx
      );
    };
  }

}

