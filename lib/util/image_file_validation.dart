
import 'package:flutter/material.dart';
import 'package:folder_thumbnail_setter/util/nest_widgets.dart';

class ImageFileValidation {

  /// shows a warning Dialog if the file is not an image
  /// and returns false.
  /// otherwise it just returns true.
  static bool validateFilePath(BuildContext context, String filePath){
    final errorMessage = _makeErrorMessage(filePath);
    if (errorMessage == null) return true;

    _showWarningDialog(context, errorMessage);
    return false;
  }

  static String? _makeErrorMessage(String filePath){
    final extensionDotIndex = filePath.lastIndexOf(".");
    if (extensionDotIndex < 0){
      return "This file has no extension!";
    }

    final String extension = filePath.substring( extensionDotIndex + 1 );
    if (!_isImageExtension(extension)){
      return "This file doesn't seem to be an image or maybe it's an unusual image type.";
    }

    return null;
  }

  static bool _isImageExtension(String extension){
    const imageExtensions = [
      "jpg", "jpeg", "png", "gif", "bmp", "webp", "tiff", "tif"
    ];

    return imageExtensions.contains(extension.toLowerCase());
  }

  static void _showWarningDialog(BuildContext context, String text){
    
    showDialog(
      context: context,
      builder: (context) {

        const textColor = Colors.black;

        return Dialog(
          backgroundColor: const Color.fromARGB(255, 199, 125, 13),
          child: nestWidgets(
            [
              (child) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 30,
                ),
                child: child,
              )
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // title
                Text(
                  "Error!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 139, 21, 21),
                  ),
                ),

                const SizedBox(height: 12),

                // error details
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );

      },
    );

  }

}
