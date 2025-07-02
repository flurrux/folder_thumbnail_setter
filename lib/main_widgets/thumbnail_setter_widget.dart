import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:folder_thumbnail_setter/folder_icon_util/generate_icon.dart';
import 'package:folder_thumbnail_setter/folder_icon_util/set_icon.dart';
import 'package:folder_thumbnail_setter/main_widgets/thumbnail_layout_widget.dart';
import 'package:folder_thumbnail_setter/util/image_util.dart';
import 'package:folder_thumbnail_setter/util/nest_widgets.dart';
import 'package:folder_thumbnail_setter/util/path_util.dart';
import 'package:folder_thumbnail_setter/util/state_builder.dart';
import 'package:folder_thumbnail_setter/util/transform.dart';
import 'package:folder_thumbnail_setter/util/value_wrapper.dart';

/// First, loads the image from the given path and then
/// displays [ThumbnailLayoutWidget] with a Button underneath
/// for setting the thumbnail (see [FolderIconSetter.set]).
/// After the thumbnail has been set, it shows feeback text.
class ThumbnailSettingWidget extends StatelessWidget {

  const ThumbnailSettingWidget({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return (
      _imageLoader(
        _mainWidget
      )
    );
  }

  Widget _imageLoader( Widget Function( ui.Image ) builder ){
    return _ImageLoader(
      imagePath: imagePath,
      builder: builder,
    );
  }

  Widget _mainWidget( ui.Image image ){
    
    return StateBuilder<bool>(
      makeInitialState: () => false,
      builder: (thumbnailDone, setThumbnailDone) {
        
        if (thumbnailDone){
          
          return _thumbnailDoneFeedback();

        }
        else {
          
          return _layoutWidgetAndSaveButton(
            image: image,
            onThumbnailSet: () => setThumbnailDone(true),
          );

        }

      },
    );

  }

  Widget _layoutWidgetAndSaveButton({
    required ui.Image image,
    required VoidCallback onThumbnailSet
  }){

    return StateBuilder<bool>(
      makeInitialState: () => false,
      builder: (thumbnailStarted, setThumbnailStarted) {
        
        if (thumbnailStarted){
          return _thumbnailStartedIndicator();
        }
        else {

          return _LayoutWidgetAndSaveButton(
            image: image,
            imagePath: imagePath,
            onCommitted: (transform, folderPath) async {
              setThumbnailStarted(true);
              await _setThumbnail(image, folderPath, transform);
              onThumbnailSet();
            }
          );

        }

      },
    );
  }

  Future<void> _setThumbnail(
    ui.Image image,
    String folderPath,
    Transform2D transform,
  ) async {

    final icon = await FolderIconGenerator.generate(
      image, transform
    );

    await FolderIconSetter.set( icon, folderPath );
  }

  Widget _thumbnailStartedIndicator(){
    return Text(
      "Please wait ...",
      style: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
    );
  }

  Widget _thumbnailDoneFeedback(){
    return nestWidgets(
      [
        (child) => Center( child: child )
      ],
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Thumbnail was set",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox( width: 8 ),
              Icon(
                Icons.check,
                color: Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          Text(
            "(Drag in another image to continue)",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


  // # for debugging ------------

  // Widget _mainWidget( ui.Image image ){

  //   return StateBuilder<ui.Image?>(
  //     makeInitialState: () => null,
  //     builder: (result, setResult) {
        
  //       return Stack(
  //         children: [
  //           _placerAndButton(
  //             image: image,
  //             onFinished: setResult
  //           ),
  //           if (result != null)
  //             _debugView(
  //               result, setResult,
  //             )
  //         ],
  //       );

  //     },
  //   );

  // }

  // Widget _debugView(
  //   ui.Image result,
  //   void Function(ui.Image?) setResult,
  // ){
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [

  //       RawImage(
  //         image: result,
  //         width: 256,
  //         height: 256,
  //       ),

  //       const SizedBox(height: 10),

  //       ElevatedButton(
  //         child: Text("Reset"),
  //         onPressed: () async {
  //           setResult(null);
  //         }
  //       ),
  //     ],
  //   );
  // }

}

class _ImageLoader extends StatelessWidget {

  final String imagePath;
  final Widget Function(ui.Image) builder;

  const _ImageLoader({
    required this.builder,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<ui.Image>(
      future: ImageUtil.loadUIImageByPath(imagePath),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (
          snapshot.connectionState == ConnectionState.waiting
          ||
          data == null
        ){
          return _loadingIndicator();
        }

        return builder(data);
      },
    );

  }

  Widget _loadingIndicator(){

    // using a static image instead of animation,
    // because the image loads synchronously and will
    // cause jank on the UI thread.
    return Icon(
      Icons.more_horiz,
      size: 60,
    );

    // return nestWidgets(
    //   [
    //     (child) => SizedBox(
    //       width: 200,
    //       height: 200,
    //       child: child,
    //     )
    //   ],
    //   CircularProgressIndicator()
    // );
  }

}

class _LayoutWidgetAndSaveButton extends StatelessWidget {

  final ui.Image image;
  final String imagePath;

  final void Function(
    Transform2D transform,
    String targetFolderPath
  ) onCommitted;

  const _LayoutWidgetAndSaveButton({
    required this.image,
    required this.imagePath,
    required this.onCommitted,
  });

  @override
  Widget build(BuildContext context) {

    // store the folderPath in a mutable object.
    // (this Widget doesn't need to update when
    // the folderPath changes)
    return _folderPathStoreBuilder(
      (folderPath){

        // store the transform in a mutable object
        return _transform2DStoreBuilder(
          (currentTransform){

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                _FolderPathDisplayAndNavigator(
                  folderPath: folderPath.value,
                  onNavigated: (newFolderPath){
                    folderPath.value = newFolderPath;
                  },
                ),

                const SizedBox(height: 10),

                ThumbnailLayoutWidget(
                  image: image,
                  imagePath: imagePath,
                  onTransformChanged: (transform) {
                    currentTransform.value = transform;
                  },
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  child: Text("Set Thumbnail"),
                  onPressed: () {
                    onCommitted(
                      currentTransform.value,
                      folderPath.value
                    );
                  }
                ),
              ],
            );

          }
        );

      }
    );


  }

  Widget _folderPathStoreBuilder(
    Widget Function(ValueWrapper<String>) builder
  ){
    return StateBuilder<ValueWrapper<String>>(
      makeInitialState: (){
        return ValueWrapper( PathUtil.getParentPath(imagePath) );
      },
      builder: (folderPathWrapper, _) {
        return builder(folderPathWrapper);
      }
    );
  }

  Widget _transform2DStoreBuilder(
    Widget Function(ValueWrapper<Transform2D>) builder
  ){
    return StateBuilder<ValueWrapper<Transform2D>>(
      makeInitialState: () => ValueWrapper(Transform2D.identity),
      builder: (currentTransform, _) {
        return builder(currentTransform);
      }
    );
  }

}

class _FolderPathDisplayAndNavigator extends StatelessWidget {

  final String folderPath;
  final void Function(String newFolderPath) onNavigated;

  const _FolderPathDisplayAndNavigator({
    required this.folderPath,
    required this.onNavigated,
  });


  @override
  Widget build(BuildContext context) {

    // we use an internal state for folderPath,
    // because the widget-level folderPath property
    // will only be set once.
    return StateBuilder<String>(
      makeInitialState: () => folderPath,
      builder: (folderPath, setFolderPath) {
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Folder:
            Text(
              "Folder:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

            const SizedBox(width: 8),
            
            _folderName(folderPath),

            const SizedBox(width: 8),

            // 'navigate up' button
            _navigateUpButton(
              folderPath,
              (folderPathNew){
                setFolderPath(folderPathNew);
                onNavigated(folderPathNew);
              }
            )
          ],
        );

      },
    );

  }

  Widget _folderName(String folderPath){
    return nestWidgets(
      [
        (child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const ui.Color.fromARGB(255, 42, 239, 167).withAlpha(30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8,
          ),
          width: 180,
          height: 40,
          child: child,
        ),
        (child) => FittedBox(
          child: child,
        )
      ],
      Text(
        PathUtil.getLeafName(folderPath),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _navigateUpButton(
    String folderPath,
    void Function(String newFolderPath) onChanged
  ){
    return IconButton.filled(
      icon: Icon(
        Icons.arrow_upward,
        color: Colors.white
      ),
      tooltip: "Navigate up",
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withAlpha(30),
      ),
      onPressed: () {
        onChanged(
          PathUtil.getParentPath(folderPath)
        );
      },
    );
  }

}
