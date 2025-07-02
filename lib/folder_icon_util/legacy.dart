
// # legacy from when i worked with img.Images:

// typedef ImageAndTranslation = ({
//   img.Image image,
//   Offset translation
// });

// static Future<img.Image> loadImageByPath(String path) async {
//   final input = File(path);
//   final bytes = await input.readAsBytes();
//   final imageName = path.substring( path.lastIndexOf("\\") );
//   final decoder = img.findDecoderForNamedImage(imageName)!;
//   return decoder.decode(bytes)!;
// }

// static Future<img.Image> _loadAssetImage(String path) async {
//   final byteData = await rootBundle.load(path);
//   final bytes = byteData.buffer.asUint8List();
//   return img.decodeImage(bytes)!;
// }

// static ImageAndTranslation _transformImage(
//   img.Image image, Transform2D transform,
// ){
//   final scale = transform.scale;

//   final scaled = img.copyResize(
//     image,
//     width: (image.width * scale).round(),
//     height: (image.height * scale).round(),
//     interpolation: img.Interpolation.cubic
//   );


//   final rotation = transform.rotation;

//   final rotated = img.copyRotate(
//     scaled,
//     angle: rotation * (180 / pi),
//     interpolation: img.Interpolation.cubic
//   );

//   // the image [rotated] fits the entire source image
//   // inside a rectangle without clipping anything.
//   // that means, the top-left corner pixel will have moved
//   // and is not fixed!
//   // we need to add the inverse of this implicit translation
//   // to the final translation.

//   final translationFromRotation = (
//     _findTopLeftCornerTranslationFromRotation(
//       Size(
//         scaled.width.toDouble(),
//         scaled.height.toDouble()
//       ),
//       rotation
//     )
//   );

//   /// we need to be careful with the coordinate systems.
//   /// in the function [_findTopLeftCornerTranslationFromRotation],
//   /// i'm using a 'positive-y-is-up' convention, but the image package
//   /// does the opposite.
//   /// so, we only need to flip the x coordinate now.
//   final translationFromRotationCompensation = Offset(
//     -translationFromRotation.dx,
//     translationFromRotation.dy
//   );

//   final translation = transform.translation + translationFromRotationCompensation;

//   // we can't really translate an image.
//   // iamgine we want to shift the image 20 pixels to the right.
//   // we would have to enlargen the image by 20 pixels and then
//   // move each pixel over by 20 units.
//   // it makes more sense to delegate this step to the caller
//   // where the compositeImage is used.
//   // this function can translate the image more easily.
//   // therefore, we're returning the scaled and rotated image,
//   // together with the computed translation.

//   return (
//     image: rotated,
//     translation: translation
//   );
// }

// static Offset _findTopLeftCornerTranslationFromRotation(
//   Size rectSize, double rotation
// ){
//   // i don't know why, but i have to flip the rotation
//   // in order for the calculation to work out.
//   // my convention for the rotational direction is probably
//   // different from flutter, but i wonder why everything
//   // else works out anyway.
//   rotation *= -1;

//   // consider all 4 corner vertices of the rotated rectangle.
//   // the minimal x and minimal y coordinates determine the
//   // origin of the images coordinate system and we want to
//   // figure out the relative position of the rotated top-left
//   // corner to it.
  
//   final w = rectSize.width;
//   final h = rectSize.height;

//   // we'll take the bottom-left corner as the center of rotation
//   final List<Offset> cornersExceptBottomLeft = [
//     Offset( w, 0 ),
//     Offset( w, h ),
//     Offset( 0, h )
//   ];

//   final cornersRotated = [
//     Offset(0, 0),
//     ...(
//       cornersExceptBottomLeft
//       .map( Transform2D.scaleAndRotatePoint(1, rotation) )
//     )
//   ];

//   final topLeftCornerRotated = cornersRotated[3];

//   final topLeftCornerNew = ExtremalPointsUtil.findMinXMaxY(cornersRotated);

//   return topLeftCornerRotated - topLeftCornerNew;
// }

// static Future<ui.Image> _convertImgToUIImage(img.Image source){
//   return _decodeFromPixels(
//     source.getBytes(alpha: source.hasAlpha ? null : 0),
//     source.width,
//     source.height,
//     ui.PixelFormat.rgba8888,
//   );
// }

// static Future<ui.Image> _decodeFromPixels(
//   Uint8List pixels,
//   int width, int height,
//   ui.PixelFormat format,
// ){
//   final completer = Completer<ui.Image>();

//   ui.decodeImageFromPixels(
//     pixels, width, height, format,
//     completer.complete,
//   );

//   return completer.future;
// }
