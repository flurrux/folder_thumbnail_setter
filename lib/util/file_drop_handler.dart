
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:folder_thumbnail_setter/util/nest_widgets.dart';

class FileDropHandler extends StatefulWidget {

  const FileDropHandler({
    super.key,
    required this.onFileDropped,
    required this.child,
  });

  final void Function(String filePath) onFileDropped;
  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _FileDropHandlerState();
  }
  
}

class _FileDropHandlerState extends State<FileDropHandler> {

  bool _fileHovering = false;

  @override
  Widget build(BuildContext context) {
    return nestWidgets(
      [
        _dropHandler
      ],
      _hoverIndicatorAndChild(),
    );
  }

  Widget _dropHandler(Widget child){
    return DropTarget(
      onDragDone: (detail) {
        setState(() {
          final String filePath = detail.files[0].path;
          _fileHovering = false;
          widget.onFileDropped(filePath);
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _fileHovering = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _fileHovering = false;
        });
      },
      child: child,
    );
  }

  Widget _hoverIndicatorAndChild(){
    return Stack(
      children: [
        widget.child,
        nestWidgets(
          [
            (child) => Positioned.fill(child: child),
            (child) => IgnorePointer(
              ignoring: true,
              child: child,
            ),
          ],
          _optionalHoverIndicator()
        )
      ],
    );
  }

  Widget _optionalHoverIndicator(){
    if (_fileHovering){
      return _hoverFileIndicator();
    }
    else {
      return SizedBox.shrink();
    }
  }

  Widget _hoverFileIndicator(){
    return nestWidgets(
      [
        (child) => _hoverContainer(
          child: child,
          color: const Color.fromARGB(255, 52, 150, 231),
        ),
        (child) => Center(child: child),
      ],
      _dropItText(),
    );
  }

  Widget _hoverContainer({
    required Widget child,
    required Color color,
  }){
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: color,
      child: child,
    );
  }

  Widget _dropItText(){
    return Text(
      "Drop it!",
      style: TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      )
    );
  }

}
