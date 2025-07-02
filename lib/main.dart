import 'package:flutter/material.dart';
import 'package:folder_thumbnail_setter/main_widgets/app.dart';
import 'package:folder_thumbnail_setter/init_window_rect.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowTitle("Folder Thumbnail Setter");
  await initWindowRect();
  runApp(const App());
}
