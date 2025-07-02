import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:folder_thumbnail_setter/util/image_util.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class FolderIconSetter {

  static Future<void> set(
    ui.Image thumbnail,
    String folderPath,
  ) async {

    final iconName = _makeIconName();
    final iconPath = "$folderPath/$iconName";
    
    final iconImg = await ImageUtil.convertUIImageToImg(thumbnail);
    await img.encodeIcoFile( iconPath, iconImg );

    // Hide the thumbnail file by setting hidden and system attributes (Windows only)
    // This uses the 'attrib' command via Process.run
    await Process.run(
      'attrib',
      ['+h', '+s', iconPath],
      runInShell: true,
    );

    // mark the folder as readonly. no worries, you will still be able to modify files inside this folder.
    // the readonly flag has no real function, as far as i learned from my research.
    await Process.run(
      'attrib',
      ['+r', folderPath],
      runInShell: true,
    );

    final desktopIniPath = "$folderPath/desktop.ini";
    
    // Create desktop.ini file to set the folder icon
    final desktopIni = File(desktopIniPath);
    await desktopIni.writeAsString(
      "[.ShellClassInfo]\n"
      "IconFile=$iconName\n"
      "IconIndex=0\n"
    );

    // Set desktop.ini file attributes (same as with the icon file)
    await Process.run(
      'attrib',
      ['+h', '+s', desktopIniPath],
      runInShell: true,
    );

    // first wait for 60 seconds and then nudge windows explorer to
    // update the folder by creating an empty file and deleting it again.
    // in my experience, this will make the thumbnail appear on the folder.
    // we don't await this function, because it would take a whole minute!
    Process.run(
      'powershell',
      ['-Command', 'Start-Sleep -Seconds 60; New-Item "$folderPath\\.refresh" -ItemType File; Remove-Item "$folderPath\\.refresh"'],
      runInShell: true,
    );

  }

  static String _makeIconName(){
    return "icon-${Uuid().v4()}.ico";
  }

}
