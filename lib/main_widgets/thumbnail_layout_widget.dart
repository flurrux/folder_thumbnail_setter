import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folder_thumbnail_setter/folder_icon_util/icon_sizes.dart';
import 'package:folder_thumbnail_setter/util/nest_widgets.dart';
import 'package:folder_thumbnail_setter/util/transform.dart';

/// This widget allows the user to
/// - move the thumbnail by dragging
/// - scale/rotate the thumbnail by zooming (press ctrl to rotate)
/// 
/// A folder icon is drawn in the background to show what
/// the end result will look like.
/// 
/// This Widget will not set the thumbnail, it's only for choosing
/// the position/rotation/scale of the final image.
class ThumbnailLayoutWidget extends StatefulWidget {

  const ThumbnailLayoutWidget({
    super.key,
    required this.image,
    required this.imagePath,
    required this.onTransformChanged,
  });
  
  final void Function(Transform2D) onTransformChanged;
  
  final ui.Image image;
  final String imagePath;

  @override
  State<StatefulWidget> createState() {
    return _ThumbnailLayoutWidgetState();
  }

}

class _ThumbnailLayoutWidgetState extends State<ThumbnailLayoutWidget> {

  
  // i want to avoid rebuilding the entire Widget
  // when moving the icon around.
  late ValueNotifier<Transform2D> _imageTransform;

  late bool _dragging;

  late final GlobalKey _rootKey;


  void _setTransform(Transform2D newTransform){
    _imageTransform.value = newTransform;
    widget.onTransformChanged(newTransform);
  }


  @override
  void initState() {
    super.initState();

    _dragging = false;


    // center the image within the icon rect

    final initialTransform = _calcInitialIconTransform(
      widget.image
    );

    _imageTransform = ValueNotifier<Transform2D>(
      initialTransform
    );

    widget.onTransformChanged(initialTransform);


    _rootKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _rootKey,
      children: [
        _folderShapeImage(),
        _iconWidget(),
        _eventHandlerBox(),
      ],
    );
  }

  Offset _getRootPosition(){
    // extract the position of the root widget
    final renderBox = _rootKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }

  Widget _folderShapeImage(){
    return Image.asset(
      "assets/folder-background.png"
    );
  }

  Widget _iconWidget(){
    return nestWidgets(
      [
        (child) => Positioned(
          top: 0, left: 0,
          child: child,
        ),

        (child) => ClipPath(
          clipper: _MaskClipper(),
          child: child,
        ),

        _iconRectOverlayIndicator,

        _transformApplication,
      ],
      _sourceImage(),
    );
  }

  // slightly transparent overlay to indicate
  // where the icon rect is
  Widget _iconRectOverlayIndicator(Widget child){
    
    final size = FolderIconSizes.fullIconSize;

    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          color: Colors.black.withAlpha(60),
        ),
        child,
      ],
    );
  }

  Widget _transformApplication(Widget child){
    return ValueListenableBuilder<Transform2D>(
      valueListenable: _imageTransform,
      builder: (context, transform, child) {
        return Transform(
          transform: transform.toMatrix4(),
          child: child
        );
      },
      child: child,
    );
  }

  Widget _eventHandlerBox(){

    const maskRect = FolderIconSizes.iconMask;

    return nestWidgets(
      [
        (child) => Positioned(
          top: maskRect.top,
          left: maskRect.left,
          child: child,
        ),
        _pointerEventHandler,
      ],
      SizedBox(
        width: maskRect.width,
        height: maskRect.height,
      ),
    );
  }

  Widget _pointerEventHandler(Widget child){
    return Listener(
      // this handler is meant to detect pointer events inside
      // the icon rectangle, independent of the image widget
      // (see _eventHandlerBox above).
      // the _eventHandlerBox doesn't draw anything persei,
      // only an empty SizedBox and as such it ignores any
      // pointer events, unless we use opaque right here.
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _dragging = true;
      },
      onPointerUp: (event) {
        _dragging = false;
      },
      onPointerMove: (event) {
        if (!_dragging) return;
        final transform = _imageTransform.value;
        _setTransform(
          transform.copyWithTranslationDelta(
            event.delta
          )
        );
      },
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent) return;
        final scrollDelta = event.scrollDelta.dy;

        final transform = _imageTransform.value;

        final mousePoint = event.position - _getRootPosition();
        
        // when control is pressed -> rotate image
        if (HardwareKeyboard.instance.isControlPressed){
          const double rotationSensitivity = 0.0007;

          _setTransform(
            Transform2D.transformAndKeepGlobalPointFixed(
              globalPoint: mousePoint,
              operation: (transform) => transform.copyWithRotationDelta(
                rotationSensitivity * scrollDelta
              ),
              transform: transform
            )
          );
        }
        // otherwise -> scale image
        else {
          const double scaleSensitivity = 0.0007;

          _setTransform(
            Transform2D.transformAndKeepGlobalPointFixed(
              globalPoint: mousePoint,
              operation: (transform) => transform.copyWithScale(
                transform.scale * (1 - scaleSensitivity * scrollDelta)
              ),
              transform: transform
            )
          );
        }
      },
      child: child,
    );
  }


  Widget _sourceImage(){
    return Image.file(
      File( widget.imagePath)
    );
  }


  static Transform2D _calcInitialIconTransform(
    ui.Image image
  ){
    final maskRect = FolderIconSizes.iconMask;
    final maskRectSize = maskRect.size;
    
    final imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble()
    );
    
    final scale = min(
      maskRectSize.width / imageSize.width,
      maskRectSize.height / imageSize.height,
    );

    final targetSize = Size(
      scale * imageSize.width,
      scale * imageSize.height
    );

    // centering
    final centeringTranslation = Offset(
      (maskRectSize.width - targetSize.width) / 2,
      (maskRectSize.height - targetSize.height) / 2,
    );

    final translation = maskRect.topLeft + centeringTranslation;

    return Transform2D(
      translation: translation,
      rotation: 0,
      scale: scale
    );
  }

}


class _MaskClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    
    path.addRRect(
      RRect.fromRectAndRadius(
        FolderIconSizes.iconMask,
        Radius.circular(6)
      )
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }

}
