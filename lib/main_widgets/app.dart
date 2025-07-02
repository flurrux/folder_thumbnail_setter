import 'package:flutter/material.dart';
import 'package:folder_thumbnail_setter/main_widgets/thumbnail_setter_widget.dart';
import 'package:folder_thumbnail_setter/util/file_drop_handler.dart';
import 'package:folder_thumbnail_setter/util/image_file_validation.dart';
import 'package:folder_thumbnail_setter/util/nest_widgets.dart';
import 'package:folder_thumbnail_setter/util/state_builder.dart';

class App extends StatelessWidget {
  const App({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _makeTheme(context),
      home: Scaffold(
        body: _body(),
      ),
    );
  }

  ThemeData _makeTheme(BuildContext context){
    return (
      ThemeData.dark(useMaterial3: true)
      .copyWith(
        visualDensity: VisualDensity.standard,
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 0.85),
      )
    );
  }


  Widget _body(){

    return StateBuilder<String?>(
      makeInitialState: () => null,
      builder: (filePath, setFilePath) {
        
        return nestWidgets(
          [
            // we can drop in a new image at any point.
            // this widget will listen and display a large
            // text "drop here" when that happens.
            (child) => _fileDropHandler(
              child, setFilePath
            ),
          ],
          _dropHintOrThumbnailPlacer(filePath),
        );

      },
    );

  }

  Widget _fileDropHandler(
    Widget child,
    void Function(String) onFileDropped
  ){
    return Builder(
      builder: (context) {
        
        return FileDropHandler(
          onFileDropped: (filePath){
            final isValidImage = ImageFileValidation.validateFilePath(context, filePath);
            if (!isValidImage) return;
            
            onFileDropped(filePath);
          },
          child: child,
        );
        
      },
    );
  }


  Widget _dropHintOrThumbnailPlacer(String? filePath){
    if (filePath == null){
      return _dropHint();
    }
    else {
      return _thumbnailSetting(filePath);
    }
  }

  Widget _dropHint(){
    return nestWidgets(
      [
        (child) => Center( child: child ),
      ],
      Text(
        "Drop an image here",
        style: TextStyle(
          fontSize: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _thumbnailSetting(String filePath){
    return nestWidgets(
      [
        (child) => Center( child: child, ),
      ],
      ThumbnailSettingWidget(
        imagePath: filePath,
      )
    );
  }
}
